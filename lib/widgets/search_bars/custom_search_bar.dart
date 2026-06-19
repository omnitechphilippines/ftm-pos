import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? textEditingController;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;

  const CustomSearchBar({super.key, this.textEditingController, this.onSubmitted, this.hintText});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.textEditingController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.textEditingController == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: widget.hintText ?? 'Search...',
      leading: const Icon(Icons.search),
      controller: _internalController,
      onSubmitted: widget.onSubmitted,
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
      elevation: WidgetStateProperty.all(0),
      trailing: <Widget>[
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _internalController,
          builder: (BuildContext context, TextEditingValue value, Widget? child) {
            return value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _internalController.clear();
                      widget.onSubmitted?.call('');
                    },
                    tooltip: 'Clear search',
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
