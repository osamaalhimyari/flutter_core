import 'package:equatable/equatable.dart';

/// One row from Google Places Autocomplete. [mainText] is the headline
/// ("Eiffel Tower"), [secondaryText] the supporting address, and [placeId]
/// is handed to Place Details to resolve coordinates when the user taps a row.
class SearchPrediction extends Equatable {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;

  const SearchPrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
  });

  @override
  List<Object?> get props => [placeId, mainText, secondaryText, description];
}
