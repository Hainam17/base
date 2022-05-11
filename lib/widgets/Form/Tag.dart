import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

class FormTag extends StatefulWidget {
  final InputDecoration? decoration;
  final String? value;
  final List? listSearch;
  final ValueChanged? onChanged;

  const FormTag(
      {Key? key, this.decoration, this.value, this.onChanged, this.listSearch})
      : super(key: key);
  @override
  _FormTagState createState() => _FormTagState();
}

class _FormTagState extends State<FormTag> {
  String _selectedValuesJson = '';
  List<Tag> _selectedTag = [];
  //TagService
  /// Mocks fetching Tag from network API with delay of 500ms.
  Future<List<Tag>> getTags(String query) async {
    await Future.delayed(Duration(milliseconds: 500), null);
    return (widget.listSearch != null)
        ? widget.listSearch!.map((e) {
      return Tag(e);
    }).toList()
        : <Tag>[]
        .where(
            (tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  @override
  void initState() {
    super.initState();
    _selectedTag = [];
    if (widget.value != null){
      _selectedTag = (widget.value)!.split(',').map((e) {
        return Tag(e);
      }).toList();
    }

  }
  @override
  void didUpdateWidget(covariant FormTag oldWidget) {
    if( widget.value != null){
      if (widget.value != oldWidget.value) {
        _selectedValuesJson = widget.value!;
      }
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void dispose() {
    _selectedTag.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterTagging<Tag>(
      initialItems: _selectedTag,
      textFieldConfiguration: TextFieldConfiguration(
        decoration: widget.decoration ??
            InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.green.withAlpha(30),
              hintText: 'Search Tags',
              labelText: 'Select Tags',
            ),
      ),
      findSuggestions: getTags,
      additionCallback: (value) {
        return Tag(value);
      },
      onAdded: (tag) {
        // api calls here, triggered when add to tag button is pressed
        return tag;
      },
      configureSuggestion: (lang) {
        return SuggestionConfiguration(
          title: Text(lang.name),
          additionWidget: Chip(
            avatar: Icon(
              Icons.add_circle,
              color: Colors.white,
            ),
            label: Text('Add New Tag'),
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
            ),
            backgroundColor: Colors.green,
          ),
        );
      },
      configureChip: (lang) {
        return ChipConfiguration(
          label: Text(lang.name),
          backgroundColor: Colors.green,
          labelStyle: TextStyle(color: Colors.white),
          deleteIconColor: Colors.white,
        );
      },
      onChanged: () {
        setState(() {
          _selectedValuesJson = _selectedTag
              .map<String>((lang) => '${lang.toJson()}')
              .join(',');
        });
        if (widget.onChanged != null)
          widget.onChanged!(_selectedValuesJson);
      },
    );
  }
}

/// Tag Class
class Tag extends Taggable {
  ///
  final String name;

  ///
  /// Creates Language
  Tag(
    this.name,
  );

  @override
  List<Object> get props => [name];

  /// Converts the class to json string.
  String toJson() => '$name';
}
