class InterestArea {
  final String areaOfInterest;
  final List<String> subInterests;

  InterestArea({required this.areaOfInterest, required this.subInterests});

  // Factory constructor to create an instance from a JSON object.
  // This assumes the JSON object structure you provided.
  factory InterestArea.fromJson(Map<String, dynamic> json) {
    String key = json.keys.first;
    List<String> subInterests = List<String>.from(json[key]);
    return InterestArea(areaOfInterest: key, subInterests: subInterests);
  }

  // Method to convert the instance back to JSON, if needed
  Map<String, dynamic> toJson() {
    return {areaOfInterest: subInterests};
  }
}
