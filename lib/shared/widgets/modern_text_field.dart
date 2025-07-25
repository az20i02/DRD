import 'package:flutter/material.dart';

class ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _borderColorAnimation;
  
  bool _isFocused = false;
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    widget.controller.addListener(() {
      setState(() {
        _hasText = widget.controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    _borderColorAnimation = ColorTween(
      begin: theme.colorScheme.outline.withOpacity(0.3),
      end: theme.colorScheme.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isFocused
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
        
        // Text field container
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _borderColorAnimation.value ?? theme.colorScheme.outline.withOpacity(0.3),
                  width: _borderAnimation.value,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                onChanged: widget.onChanged,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Enter ${widget.label.toLowerCase()}',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: widget.prefixIcon != null ? 16 : 20,
                    vertical: 20,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16, right: 12),
                          child: Icon(
                            widget.prefixIcon,
                            color: _isFocused
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                            size: 22,
                          ),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: widget.suffixIcon,
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 