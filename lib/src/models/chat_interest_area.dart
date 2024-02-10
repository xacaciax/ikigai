class InterestArea {
  final String areaOfInterest;
  final List<String> subInterests;

  InterestArea({required this.areaOfInterest, required this.subInterests});

  factory InterestArea.fromJson(Map<String, dynamic> json) {
    String key = json.keys.first;
    List<String> subInterests = List<String>.from(json[key]);
    return InterestArea(areaOfInterest: key, subInterests: subInterests);
  }

  Map<String, dynamic> toJson() {
    return {areaOfInterest: subInterests};
  }
}
