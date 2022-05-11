import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'Select.dart';

// ignore: must_be_immutable
class FormSelectRegionAddress extends StatefulWidget {
  final Function? onChangeProvince, onChangeDistrict, onChangeWard;
  final String? errorProvince, errorDistrict, errorWard;
  final String? labelProvince, labelDistrict, labelWard;
  String? provinceId, districtId, wardId;
  final String? defaultProvinceId;
  final bool isOneLine;
  final InputDecoration? decoration;
  final String? description;
  final String? nationId;
  final double space;

  FormSelectRegionAddress({
    Key? key,
    @required this.onChangeProvince,
    @required this.onChangeDistrict,
    this.onChangeWard,
    this.errorProvince,
    this.errorDistrict,
    this.errorWard,
    this.provinceId,
    this.districtId,
    this.wardId,
    this.labelProvince,
    this.labelDistrict,
    this.space = 10.0,
    this.labelWard, this.defaultProvinceId,this.decoration,this.description, this.isOneLine:false,
    this.nationId,
  }) : super(key: key);
  @override
  _FormSelectRegionAddressState createState() => _FormSelectRegionAddressState();
}

class _FormSelectRegionAddressState extends State<FormSelectRegionAddress> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: (widget.isOneLine)?
    Column(
      children: [
        FormSelect(
          decoration: widget.decoration,
          description: widget.description??'Chọn'.lang(),
          errorText: (widget.errorProvince != null)?widget.errorProvince:null,
          labelText: (widget.labelProvince != null)?widget.labelProvince:'Tỉnh, thành'.lang(),
          service: "Content.Region.selectProvinces",
          value: widget.provinceId,
          extraParams: {
            if(!empty(widget.nationId))'parentId': widget.nationId
          },
          onChanged: (val) {
            widget.onChangeProvince!(val);
            setState(() {
              widget.provinceId = val;
              widget.districtId = null;
              widget.wardId = null;
            });
          },
        ),
        if(!empty(widget.decoration))
          SizedBox(height: widget.space),
        FormSelect(
          decoration: (widget.decoration != null)?widget.decoration!.copyWith(
            labelText: (widget.labelDistrict != null)?widget.labelDistrict:'Quận, huyện'.lang(),
            errorText: (widget.errorDistrict != null)?widget.errorDistrict:null,
          ):null,
          description: widget.description??'Chọn'.lang(),
          labelText: (widget.labelDistrict != null)?widget.labelDistrict:'Quận, huyện'.lang(),
          errorText: (widget.errorDistrict != null)?widget.errorDistrict:null,
          service: "Content.Region.selectDistricts",
          extraParams: {'provinceId': !empty(widget.defaultProvinceId)?widget.defaultProvinceId:widget.provinceId},
          value: widget.districtId,
          onChanged: (val) {
            widget.onChangeDistrict!(val);
            setState(() {
              widget.districtId = val;
              widget.wardId = null;
            });
          },
        ),
        if(!empty(widget.decoration) && widget.onChangeWard != null)
          SizedBox(height: widget.space),
        if(widget.onChangeWard != null)FormSelect(
          decoration: widget.decoration,
          description: widget.description??'Chọn'.lang(),
          labelText: (widget.labelWard != null)?widget.labelWard:'Phường, xã'.lang(),
          errorText: (widget.errorWard != null)?widget.errorWard:null,
          service: "Content.Region.selectWards",
          extraParams: {'districtId': widget.districtId},
          value: widget.wardId,
          onChanged: (val) {
            widget.onChangeWard!(val);
            setState(() {
              widget.wardId = val;
            });
          },
        ),
      ],
    ):
    Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if(empty(widget.defaultProvinceId))Expanded(
            flex: 1,
            child: FormSelect(
              decoration: widget.decoration,
              description: widget.description??'Chọn'.lang(),
              errorText: (widget.errorProvince != null)?widget.errorProvince:null,
              labelText: (widget.labelProvince != null)?widget.labelProvince:'Tỉnh, thành'.lang(),
              service: "Content.Region.selectProvinces",
              value: widget.provinceId,
              onChanged: (val) {
                widget.onChangeProvince!(val);
                setState(() {
                  widget.provinceId = val;
                  widget.districtId = null;
                  widget.wardId = null;
                });
              },
            ),
          ),
          if(empty(widget.defaultProvinceId))SizedBox(width: widget.space),
          Expanded(
            flex: 1,
            child: FormSelect(
              decoration: widget.decoration,
              description: widget.description??'Chọn'.lang(),
              labelText: (widget.labelDistrict != null)?widget.labelDistrict:'Quận, huyện'.lang(),
              errorText: (widget.errorDistrict != null)?widget.errorDistrict:null,
              service: "Content.Region.selectDistricts",
              extraParams: {'provinceId': !empty(widget.defaultProvinceId)?widget.defaultProvinceId:widget.provinceId},
              value: widget.districtId,
              onChanged: (val) {
                widget.onChangeDistrict!(val);
                setState(() {
                  widget.districtId = val;
                  widget.wardId = null;
                });
              },
            ),
          ),
          SizedBox(width: widget.space),
          Expanded(
              flex: 1,
              child: FormSelect(
                decoration: widget.decoration,
                description: widget.description??'Chọn'.lang(),
                labelText: (widget.labelWard != null)?widget.labelWard:'Phường, xã'.lang(),
                errorText: (widget.errorWard != null)?widget.errorWard:null,
                service: "Content.Region.selectWards",
                extraParams: {'districtId': widget.districtId},
                value: widget.wardId,
                onChanged: (val) {
                  widget.onChangeWard!(val);
                  setState(() {
                    widget.wardId = val;
                  });
                },
              )
          ),
        ],
      ),
    );
  }
}
