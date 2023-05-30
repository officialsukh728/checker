
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:checker/utils/widgets/helpers.dart';

class GeneralBtn extends StatefulWidget {
  const GeneralBtn({
    Key? key,
    required this.title,
    required this.onTap,
    this.loading = false,
    this.color = secondary,
    this.textColor = Colors.white,
    this.xPadding,
    this.fontSize,
    this.fontWeight,
    this.yPadding,
    this.enable = true,
    this.leftIcon,
    this.rightIcon,
    this.iconColor,
    this.iconSize,
    this.borderRadius,
    this.lined,
    this.borderRadiusClass,
    this.borderColor,
    this.smallLoading = false,
  }) : super(key: key);

  final String title;
  final Function? onTap;
  final bool loading;
  final Color? color;
  final Color? textColor;
  final double? xPadding;
  final double? yPadding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool enable;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final Color? iconColor;
  final double? iconSize;
  final double? borderRadius;
  final bool? lined;
  final bool smallLoading;
  final BorderRadius? borderRadiusClass;
  final Color? borderColor;

  @override
  GeneralBtnState createState() => GeneralBtnState();
}

class GeneralBtnState extends State<GeneralBtn> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.enable
          ? widget.loading
              ? null
              : widget.onTap as void Function()?
          : null,
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.resolveWith((states) => widget.loading
                  ? Colors.grey.withOpacity(0.2)
                  : widget.enable
                      ? widget.color ?? secondary
                      : Colors.grey.withOpacity(0.5)),
          shape: MaterialStateProperty.resolveWith((states) =>
              RoundedRectangleBorder(
                  side: BorderSide(
                      color: widget.lined == true
                          ? widget.borderColor ?? Colors.grey.withOpacity(0.3)
                          : Colors.transparent,
                      width: widget.lined == true ? 1 : 0),
                  borderRadius: widget.borderRadiusClass ??
                      BorderRadius.circular(widget.borderRadius ?? 8)))),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.xPadding ?? 5,
          vertical: widget.yPadding ??
              (defaultTargetPlatform == TargetPlatform.linux ||
                      defaultTargetPlatform == TargetPlatform.macOS ||
                      defaultTargetPlatform == TargetPlatform.windows
                  ? 10
                  : 0.0),
        ),
        child: widget.loading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  customLoader(height: 18, width: 18),
                  if (widget.smallLoading == false) xWidth(10),
                  if (widget.smallLoading == false)
                    Text('Please Wait ',
                        style: TextStyle(
                            color: widget.enable
                                ? secondary
                                : Colors.black.withOpacity(0.6),
                            fontSize: widget.fontSize ?? 14,
                            fontFamily: 'Lato',
                            fontWeight: widget.fontWeight ?? FontWeight.w500))
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.leftIcon != null)
                    Icon(widget.leftIcon,
                        size: widget.iconSize ?? 20,
                        color: widget.enable == true
                            ? (widget.iconColor ?? (widget.textColor ?? white))
                            : Colors.black.withOpacity(0.6)),
                  if (widget.leftIcon != null) xWidth(7),
                  Text(
                    widget.title,
                    style: TextStyle(
                        color: widget.enable
                            ? widget.textColor ?? Colors.white
                            : Colors.black.withOpacity(0.6),
                        fontSize: widget.fontSize ?? 14,
                        fontFamily: 'Lato',
                        fontWeight: widget.fontWeight ?? FontWeight.w500),
                  ),
                  if (widget.rightIcon != null) xWidth(7),
                  if (widget.rightIcon != null)
                    Icon(widget.rightIcon,
                        size: widget.iconSize ?? 20,
                        color: widget.enable == true
                            ? (widget.iconColor ?? (widget.textColor ?? white))
                            : Colors.black.withOpacity(0.6)),
                ],
              ),
      ),
    );
  }
}
