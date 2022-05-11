import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:vhv_basic/import.dart';
import 'package:vhv_basic/widgets/MapViewer.dart';

class FormLocationPicker extends StatefulWidget {
  final dynamic value;
  final ValueChanged? onChanged;
  final bool enabled;
  final InputDecoration? decoration;
  final Widget? trailing;
  final String? errorText;
  final double? zoom;
  final int? precision;
  final Future<List<double>> Function()? defaultValueBuilder;

  const FormLocationPicker({Key? key, this.value, this.onChanged,
    this.enabled = true, this.decoration, this.trailing,
    this.errorText, this.defaultValueBuilder, this.zoom, this.precision})
      : super(key: key);

  @override
  _FormLocationPickerState createState() => _FormLocationPickerState();
}

class _FormLocationPickerState extends State<FormLocationPicker> {
  TextEditingController? textEditingController;
  String? _labelText;
  String? _hintText;
  List<double>? defaultValue;

  @override
  void initState() {
    if (widget.decoration != null) {
      _labelText = widget.decoration!.labelText;
      _hintText = widget.decoration!.hintText;
    }
    textEditingController = TextEditingController();
    _init();
    setText();
    super.initState();
  }

  _init() async {
    if (widget.defaultValueBuilder != null) {
      defaultValue = await widget.defaultValueBuilder!();
      if (mounted) setState(() {

      });
    }
  }

  setText([String? result]) {
    if (!empty(result)) {
      textEditingController!.text = result!;
      if (widget.onChanged != null) widget.onChanged!(result);
    } else {
      textEditingController!.text = _hintText ?? 'Chọn'.lang();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !empty(widget.enabled)
          ? () async {
        final _result = await appNavigator.push(FormLocationPickerContent(
          value: widget.value,
          zoom: widget.zoom,
          defaultValue: defaultValue,
        ));
        if (!empty(_result) && _result is LatLng) {
          String result = '';
          if (widget.precision != null) {
            result =
            '${_result.latitude.toStringAsPrecision(widget.precision!)};${_result
                .longitude.toStringAsPrecision(widget.precision!)}';
          } else {
            result = '${_result.latitude};${_result.longitude}';
          }
          setText(result);
        }
      } : null,
      child: Container(
        decoration: (empty(widget.enabled)
            ? BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.grey.withOpacity(0.1),
        )
            : null),
        child: TextFormField(
          controller: textEditingController,
          enabled: false,
          maxLines: 1,
          decoration: (widget.decoration != null)
              ? widget.decoration!.copyWith(
            errorText: !empty(widget.errorText)
                ? widget.errorText!.lang()
                : null,
            hintText: _hintText ?? ''.lang(),
            labelText: _labelText ?? ''.lang(),
            suffixIcon:
            widget.trailing ?? const Icon(Icons.location_on_outlined),
          )
              : InputDecoration(
            // labelText: state.title,
            errorText: !empty(widget.errorText)
                ? widget.errorText!.lang()
                : null,
            hintText: _hintText!.lang(),
            labelText: _labelText!.lang(),
            border: const UnderlineInputBorder(borderSide: BorderSide()),
            suffixIcon:
            widget.trailing ?? Icon(Icons.location_on_outlined),
            errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red)
            ),
            errorStyle: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class FormLocationPickerContent extends StatefulWidget {
  final dynamic value;
  final double? zoom;
  final List<double>? defaultValue;

  FormLocationPickerContent(
      {Key? key, this.value, this.defaultValue, this.zoom}) : super(key: key);

  @override
  _FormLocationPickerContentState createState() =>
      _FormLocationPickerContentState();
}

class _FormLocationPickerContentState extends State<FormLocationPickerContent> {
  List<double>? value;

  @override
  void initState() {
    value = [21.02945, 105.854444];
    if (widget.defaultValue != null) {
      value = widget.defaultValue;
    }

    getValue();
    super.initState();
  }

  getValue() {
    if (!empty(widget.value)) {
      List _latLng = (widget.value is String) ? widget.value.split(';') : widget
          .value;
      value = [parseDouble(_latLng[0]), parseDouble(_latLng[1])];
    }
  }

  @override
  void didUpdateWidget(covariant FormLocationPickerContent oldWidget) {
    if (widget.defaultValue != null) {
      value = widget.defaultValue;
    }
    getValue();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapViewer(
        latlng: value,
        zoom: widget.zoom ?? 14,
        hasPicker: true,
      ),
    );
  }
}