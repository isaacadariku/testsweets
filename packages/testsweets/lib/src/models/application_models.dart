import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:testsweets/src/enums/widget_type.dart';
import 'package:testsweets/src/extensions/widget_type_extension.dart';

part 'application_models.freezed.dart';
part 'application_models.g.dart';

/// Describes a widget that we will use to driver the app with
@freezed
class WidgetDescription with _$WidgetDescription {
  const WidgetDescription._();

  factory WidgetDescription({
    /// The Id from the firebase backend
    String? id,

    /// The name of the view this widget was captured on
    required String viewName,

    /// The orignal name of the view this widget was captured on before the prettify
    required String originalViewName,

    /// The name we want to use when referring to the widget in the scripts
    required String name,

    /// The type of the widget that's being added
    required WidgetType widgetType,

    /// The position we defined for he widget
    required WidgetPosition position,
  }) = _WidgetDescription;
  factory WidgetDescription.addView(
          {required String viewName, required String originalViewName}) =>
      WidgetDescription(
          viewName: viewName,
          originalViewName: originalViewName,
          name: '',
          widgetType: WidgetType.view,
          position: WidgetPosition(x: 0, y: 0));

  factory WidgetDescription.addAtPosition(
          {required WidgetType widgetType, WidgetPosition? widgetPosition}) =>
      WidgetDescription(
          originalViewName: '',
          viewName: '',
          name: '',
          widgetType: widgetType,
          position: widgetPosition ?? WidgetPosition(x: 0, y: 0));

  factory WidgetDescription.fromJson(Map<String, dynamic> json) =>
      _$WidgetDescriptionFromJson(json);

  String get automationKey => widgetType == WidgetType.view
    ? '$viewName\_${widgetType.shortName}'
      : '$viewName\_${widgetType.shortName}\_$name';
}

/// The position of the widget as we captured it on device
@freezed
class WidgetPosition with _$WidgetPosition {
  factory WidgetPosition({
    required double x,
    required double y,
  }) = _WidgetPosition;

  factory WidgetPosition.fromJson(Map<String, dynamic> json) =>
      _$WidgetPositionFromJson(json);
}
