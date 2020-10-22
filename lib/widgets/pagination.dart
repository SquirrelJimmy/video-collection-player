import 'package:flutter/material.dart';

class PaginationControl extends StatefulWidget {
  int maxPage;
  int page;
  GestureTapCallback toNextPage;
  GestureTapCallback toPrevPage;
  GestureTapCallback toFirstPage;
  GestureTapCallback toLastPage;

  Function(String) toSkipPage;

  PaginationControl({
    Key key,
    this.maxPage,
    this.page,
    this.toFirstPage,
    this.toLastPage,
    this.toNextPage,
    this.toPrevPage,
    this.toSkipPage,
  });

  @override
  _PaginationControl createState() => _PaginationControl();

  static Widget radiusButton({
    @required BuildContext context,
    Widget child,
    double width = 40,
    double height = 40,
    GestureDragCancelCallback onTap,
  }) {
    return ClipOval(
      child: Material(
        color: Theme.of(context).primaryColor, // button color
        child: InkWell(
          // splashColor: Colors.red, // inkwell color
          child: SizedBox(width: width, height: height, child: child),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }
}

class _PaginationControl extends State<PaginationControl> {
  TextEditingController _textEditingController = TextEditingController();
  OverlayEntry _inputOverlayEntry;
  // final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = '${widget.page}';
  }

  @override
  void dispose() {
    // _focusScopeNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          PaginationControl.radiusButton(
            context: context,
            width: 28,
            height: 28,
            child: Icon(
              Icons.first_page,
              color: Colors.white,
              size: 22,
            ),
            onTap: () {
              if (widget.page == 1) return;
              widget.toFirstPage();
            },
          ),
          PaginationControl.radiusButton(
            context: context,
            width: 28,
            height: 28,
            child: Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 22,
            ),
            onTap: () {
              if (widget.page == 1) return;
              widget.toPrevPage();
            },
          ),
          Container(
            width: 100,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _toggleInput(),
              child: Text(
                '${widget.page}/${widget.maxPage}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          PaginationControl.radiusButton(
            context: context,
            width: 28,
            height: 28,
            child: Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 22,
            ),
            onTap: () {
              if (widget.page == widget.maxPage) return;
              widget.toNextPage();
            },
          ),
          PaginationControl.radiusButton(
            context: context,
            width: 28,
            height: 28,
            child: Icon(
              Icons.last_page,
              color: Colors.white,
              size: 22,
            ),
            onTap: () {
              if (widget.page == widget.maxPage) return;
              widget.toLastPage();
            },
          ),
        ],
      ),
    );
  }

  inputBuild() {
    _inputOverlayEntry = OverlayEntry(builder: (context) {
      return Scaffold(
        backgroundColor: Color(0x00000000),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _inputOverlayEntry.remove();
            _inputOverlayEntry = null;
          },
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: Color(0xFFFFFFFF),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: FocusScope(
                      // autofocus: true,
                      child: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        controller: _textEditingController,
                        onSubmitted: _onSubmitted,
                        textInputAction: TextInputAction.go,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
    Overlay.of(context).insert(_inputOverlayEntry);
  }

  _onSubmitted(String value) {
    if (widget.page.toString() == value) {
      _inputOverlayEntry.remove();
      _inputOverlayEntry = null;
      return;
    }
    int intValue = int.parse(value);
    if (intValue >= widget.maxPage) {
      intValue = widget.maxPage;
    }

    if (intValue <= 1) {
      intValue = 1;
    }
    _textEditingController.text = '$intValue';
    widget.toSkipPage != null ? widget.toSkipPage(value) : null;
    _inputOverlayEntry.remove();
    _inputOverlayEntry = null;
  }

  _toggleInput() {
    setState(() {
      _textEditingController.text = '${widget.page}';
    });
    inputBuild();
  }
}
