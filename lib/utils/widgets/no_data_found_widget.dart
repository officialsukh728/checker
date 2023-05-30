import 'package:flutter/cupertino.dart';
import 'package:checker/utils/widgets/general_btn.dart';
import 'package:checker/utils/widgets/helpers.dart';

class NotDataFoundRefresh extends StatelessWidget {
  final String message;
  final bool scroll;
  final bool showOnTap;
  final VoidCallback? onTap;

  const NotDataFoundRefresh({
    Key? key,
    this.scroll = true,
    required this.message,
    this.onTap,
    this.showOnTap=true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (scroll) {
      return SingleChildScrollView(
        child: _getBody(context),
      );
    } else {
      return _getBody(context);
    }
  }

  Widget _getBody(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 20),
          ),
          yHeight(10),
          if(showOnTap)
          GeneralBtn(
            title: 'Refresh',
            onTap: onTap,
            // lined: true,
            // color: Colors.black,
            // textColor: Colors.white,
          ),
        ],
      );
}
