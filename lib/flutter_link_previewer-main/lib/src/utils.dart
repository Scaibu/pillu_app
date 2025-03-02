import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' hide Element;
import 'package:html/dom.dart' show Document, Element;
import 'package:html/parser.dart' as parser show parse;
import 'package:http/http.dart' as http show get;
import 'package:http/src/response.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart'
    show PreviewData, PreviewDataImage;

import 'package:pillu_app/flutter_link_previewer-main/lib/src/types.dart';

String _calculateUrl(final String baseUrl, final String? proxy) {
  if (proxy != null) {
    return '$proxy$baseUrl';
  }

  return baseUrl;
}

String? _getMetaContent(final Document document, final String propertyValue) {
  final List<Element> meta = document.getElementsByTagName('meta');
  final Element element = meta.firstWhere(
    (final Element e) => e.attributes['property'] == propertyValue,
    orElse: () => meta.firstWhere(
      (final Element e) => e.attributes['name'] == propertyValue,
      orElse: () => Element.tag(null),
    ),
  );

  return element.attributes['content']?.trim();
}

bool _hasUTF8Charset(final Document document) {
  final Element emptyElement = Element.tag(null);
  final List<Element> meta = document.getElementsByTagName('meta');
  final Element element = meta.firstWhere(
    (final Element e) => e.attributes.containsKey('charset'),
    orElse: () => emptyElement,
  );
  if (element == emptyElement) {
    return true;
  }
  return element.attributes['charset']!.toLowerCase() == 'utf-8';
}

String? _getTitle(final Document document) {
  final List<Element> titleElements = document.getElementsByTagName('title');
  if (titleElements.isNotEmpty) {
    return titleElements.first.text;
  }

  return _getMetaContent(document, 'og:title') ??
      _getMetaContent(document, 'twitter:title') ??
      _getMetaContent(document, 'og:site_name');
}

String? _getDescription(final Document document) =>
    _getMetaContent(document, 'og:description') ??
    _getMetaContent(document, 'description') ??
    _getMetaContent(document, 'twitter:description');

List<String> _getImageUrls(final Document document, final String baseUrl) {
  final List<Element> meta = document.getElementsByTagName('meta');
  String attribute = 'content';
  List<Element> elements = meta
      .where(
        (final Element e) =>
            e.attributes['property'] == 'og:image' ||
            e.attributes['property'] == 'twitter:image',
      )
      .toList();

  if (elements.isEmpty) {
    elements = document.getElementsByTagName('img');
    attribute = 'src';
  }

  return elements.fold<List<String>>(<String>[],
      (final List<String> previousValue, final Element element) {
    final String? actualImageUrl = _getActualImageUrl(
      baseUrl,
      element.attributes[attribute]?.trim(),
    );

    return actualImageUrl != null
        ? <String>[...previousValue, actualImageUrl]
        : previousValue;
  });
}

String? _getActualImageUrl(final String baseUrl, String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty || imageUrl.startsWith('data')) {
    return null;
  }

  if (imageUrl.contains('.svg') || imageUrl.contains('.gif')) {
    return null;
  }

  if (imageUrl.startsWith('//')) {
    imageUrl = 'https:$imageUrl';
  }

  if (!imageUrl.startsWith('http')) {
    if (baseUrl.endsWith('/') && imageUrl.startsWith('/')) {
      imageUrl = '${baseUrl.substring(0, baseUrl.length - 1)}$imageUrl';
    } else if (!baseUrl.endsWith('/') && !imageUrl.startsWith('/')) {
      imageUrl = '$baseUrl/$imageUrl';
    } else {
      imageUrl = '$baseUrl$imageUrl';
    }
  }

  return imageUrl;
}

Future<Size> _getImageSize(final String url) {
  final Completer<Size> completer = Completer<Size>();
  final ImageStream stream =
      Image.network(url).image.resolve(ImageConfiguration.empty);
  late ImageStreamListener streamListener;

  void onError(final Object error, final StackTrace? stackTrace) {
    completer.completeError(error, stackTrace);
  }

  void listener(final ImageInfo info, final bool _) {
    if (!completer.isCompleted) {
      completer.complete(
        Size(
          height: info.image.height.toDouble(),
          width: info.image.width.toDouble(),
        ),
      );
    }
    stream.removeListener(streamListener);
  }

  streamListener = ImageStreamListener(listener, onError: onError);

  stream.addListener(streamListener);
  return completer.future;
}

Future<String> _getBiggestImageUrl(
  final List<String> imageUrls,
  final String? proxy,
) async {
  if (imageUrls.length > 5) {
    imageUrls.removeRange(5, imageUrls.length);
  }

  String currentUrl = imageUrls[0];
  double currentArea = 0;

  await Future.forEach(imageUrls, (final String url) async {
    final Size size = await _getImageSize(_calculateUrl(url, proxy));
    final double area = size.width * size.height;
    if (area > currentArea) {
      currentArea = area;
      currentUrl = _calculateUrl(url, proxy);
    }
  });

  return currentUrl;
}

/// Parses provided text and returns [PreviewData] for the first found link.
Future<PreviewData> getPreviewData(
  final String text, {
  final String? proxy,
  final Duration? requestTimeout,
  final String? userAgent,
}) async {
  const PreviewData previewData = PreviewData();

  String? previewDataDescription;
  PreviewDataImage? previewDataImage;
  String? previewDataTitle;
  String? previewDataUrl;

  try {
    final RegExp emailRegexp = RegExp(regexEmail, caseSensitive: false);
    final String textWithoutEmails = text
        .replaceAllMapped(
          emailRegexp,
          (final Match match) => '',
        )
        .trim();
    if (textWithoutEmails.isEmpty) {
      return previewData;
    }

    final RegExp urlRegexp = RegExp(regexLink, caseSensitive: false);
    final Iterable<RegExpMatch> matches =
        urlRegexp.allMatches(textWithoutEmails);
    if (matches.isEmpty) {
      return previewData;
    }

    String url = textWithoutEmails.substring(
      matches.first.start,
      matches.first.end,
    );

    if (!url.toLowerCase().startsWith('http')) {
      url = 'https://$url';
    }
    previewDataUrl = _calculateUrl(url, proxy);
    final Uri uri = Uri.parse(previewDataUrl);
    final Response response = await http.get(uri, headers: <String, String>{
      'User-Agent': userAgent ?? 'WhatsApp/2',
    }).timeout(requestTimeout ?? const Duration(seconds: 5));
    final Document document = parser.parse(utf8.decode(response.bodyBytes));

    final RegExp imageRegexp = RegExp(regexImageContentType);

    if (imageRegexp.hasMatch(response.headers['content-type'] ?? '')) {
      final Size imageSize = await _getImageSize(previewDataUrl);
      previewDataImage = PreviewDataImage(
        height: imageSize.height,
        url: previewDataUrl,
        width: imageSize.width,
      );
      return PreviewData(
        image: previewDataImage,
        link: previewDataUrl,
      );
    }

    if (!_hasUTF8Charset(document)) {
      return previewData;
    }

    final String? title = _getTitle(document);
    if (title != null) {
      previewDataTitle = title.trim();
    }

    final String? description = _getDescription(document);
    if (description != null) {
      previewDataDescription = description.trim();
    }

    final List<String> imageUrls = _getImageUrls(document, url);

    Size imageSize;
    String imageUrl;

    if (imageUrls.isNotEmpty) {
      imageUrl = imageUrls.length == 1
          ? _calculateUrl(imageUrls[0], proxy)
          : await _getBiggestImageUrl(imageUrls, proxy);

      imageSize = await _getImageSize(imageUrl);
      previewDataImage = PreviewDataImage(
        height: imageSize.height,
        url: imageUrl,
        width: imageSize.width,
      );
    }
    return PreviewData(
      description: previewDataDescription,
      image: previewDataImage,
      link: previewDataUrl,
      title: previewDataTitle,
    );
  } catch (e) {
    return PreviewData(
      description: previewDataDescription,
      image: previewDataImage,
      link: previewDataUrl,
      title: previewDataTitle,
    );
  }
}

/// Regex to check if text is email.
const String regexEmail = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}';

/// Regex to check if content type is an image.
const String regexImageContentType = r'image\/*';

/// Regex to find all links in the text.
const String regexLink =
    r'((http|ftp|https):\/\/)?([\w_-]+(?:(?:\.[\w_-]*[a-zA-Z_][\w_-]*)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?[^\.\s]';
