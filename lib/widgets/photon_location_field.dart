import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PhotonLocationField extends StatefulWidget {
  final TextEditingController controller;
  final Function(double latitude, double longitude, String address) onPlaceSelected;
  final String? initialValue;

  const PhotonLocationField({
    super.key,
    required this.controller,
    required this.onPlaceSelected,
    this.initialValue,
  });

  @override
  State<PhotonLocationField> createState() => _PhotonLocationFieldState();
}

class _PhotonLocationFieldState extends State<PhotonLocationField> {
  List<PhotonPlace> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;
  final _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      widget.controller.text = widget.initialValue!;
    }
    widget.controller.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _removeOverlay();
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (widget.controller.text.length >= 3) {
        _searchPlaces(widget.controller.text);
      } else {
        setState(() {
          _suggestions = [];
          _removeOverlay();
        });
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    setState(() => _isLoading = true);

    try {
      // Photon API - Free OpenStreetMap geocoding
      // Restrict to Sri Lanka with bbox parameter
      // Sri Lanka bounding box: [lon_min, lat_min, lon_max, lat_max]
      final url = Uri.parse(
        'https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}'
        '&lon=80.7718&lat=7.8731' // Center on Sri Lanka
        '&limit=5'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List;

        setState(() {
          _suggestions = features
              .map((feature) => PhotonPlace.fromJson(feature))
              .toList();
          _isLoading = false;
        });

        if (_suggestions.isNotEmpty && _focusNode.hasFocus) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      } else {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Photon search error: $e');
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getTextFieldWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // Below the text field
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: _buildSuggestionsList(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getTextFieldWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 300;
  }

  Widget _buildSuggestionsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a1a16) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey[200]!,
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final place = _suggestions[index];
          return InkWell(
            onTap: () {
              widget.controller.text = place.name;
              widget.onPlaceSelected(place.latitude, place.longitude, place.name);
              _removeOverlay();
              _focusNode.unfocus();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey[200]!,
                    width: index < _suggestions.length - 1 ? 1 : 0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 20,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (place.country != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            place.country!,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey[200]!,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search for a location...',
            hintStyle: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: isDark ? Colors.white54 : Colors.grey[400],
            ),
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          widget.controller.clear();
                          _removeOverlay();
                        },
                      )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class PhotonPlace {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? city;
  final String? state;

  PhotonPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.city,
    this.state,
  });

  factory PhotonPlace.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>;
    final geometry = json['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    // Build display name from available fields
    String displayName = properties['name'] ?? properties['street'] ?? '';

    if (properties['city'] != null) {
      displayName += displayName.isEmpty ? properties['city'] : ', ${properties['city']}';
    } else if (properties['county'] != null) {
      displayName += displayName.isEmpty ? properties['county'] : ', ${properties['county']}';
    }

    if (properties['state'] != null) {
      displayName += ', ${properties['state']}';
    }

    return PhotonPlace(
      name: displayName.isEmpty ? 'Unknown Location' : displayName,
      latitude: coordinates[1] as double,
      longitude: coordinates[0] as double,
      country: properties['country'] as String?,
      city: properties['city'] as String?,
      state: properties['state'] as String?,
    );
  }
}
