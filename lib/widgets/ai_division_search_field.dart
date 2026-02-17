import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ai_division_model.dart';
import '../services/ai_division_service.dart';

class AIDivisionSearchField extends StatefulWidget {
  final AIDivision? initialValue;
  final Function(AIDivision?) onChanged;
  final String? Function(AIDivision?)? validator;

  const AIDivisionSearchField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.validator,
  });

  @override
  State<AIDivisionSearchField> createState() => _AIDivisionSearchFieldState();
}

class _AIDivisionSearchFieldState extends State<AIDivisionSearchField> {
  final TextEditingController _controller = TextEditingController();
  final AIDivisionService _service = AIDivisionService();
  final FocusNode _focusNode = FocusNode();

  AIDivision? _selectedDivision;
  List<AIDivision> _searchResults = [];
  bool _isLoading = false;
  bool _showResults = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectedDivision = widget.initialValue;
      _controller.text = widget.initialValue!.displayName;
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Delay hiding results to allow tap events to process
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _showResults = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Clear selected division when user types
    if (_selectedDivision != null && query != _selectedDivision!.displayName) {
      _selectedDivision = null;
      widget.onChanged(null);
    }

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showResults = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final result = await _service.search(query: query, limit: 20);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result['success']) {
            _searchResults = result['data'] as List<AIDivision>;
          } else {
            _searchResults = [];
          }
        });
      }
    });
  }

  void _selectDivision(AIDivision division) {
    setState(() {
      _selectedDivision = division;
      _controller.text = division.displayName;
      _showResults = false;
      _searchResults = []; // Clear search results
    });
    _focusNode.unfocus();
    widget.onChanged(division);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey[200]!,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Search AI Division (e.g., Homagama, Colombo)',
              hintStyle: GoogleFonts.spaceGrotesk(
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: isDark ? Colors.white54 : Colors.grey[400],
              ),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF9dac17),
                          ),
                        ),
                      ),
                    )
                  : (_selectedDivision != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedDivision = null;
                              _controller.clear();
                              _searchResults = [];
                              _showResults = false;
                            });
                            widget.onChanged(null);
                          },
                        )
                      : null),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (_showResults && _searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.grey[200]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final division = _searchResults[index];
                return GestureDetector(
                  onTap: () => _selectDivision(division),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.grey[50],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          division.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9dac17)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF9dac17)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                division.district,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  color: const Color(0xFF9dac17),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                division.province,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  color:
                                      isDark ? Colors.white54 : Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (_showResults && !_isLoading && _searchResults.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_off,
                  color: isDark ? Colors.white54 : Colors.grey[400],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No divisions found. Try searching by district or province.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
