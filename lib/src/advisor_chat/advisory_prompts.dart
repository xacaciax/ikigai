// TODO tune these prompts
// https://platform.openai.com/docs/guides/prompt-engineering/tactic-use-intent-classification-to-identify-the-most-relevant-instructions-for-a-user-query

/// Phases of conversation that map to system level prompts
const Map<String, dynamic> advisoryPrompts = {
  'introduction': introduction,
  'questions': questions,
  'surveys': surveyPrompts,
  'suggestions': suggestions,
};

const Map<String, String> surveyPrompts = {
  'interests': interests,
  'careerValues': careerValues,
  'strengths': strengths,
};

const Map<String, String> adminPrompts = {
  'requestSummary': requestSummary,
  'systemRequestSummary': systemRequestSummary,
};

const Map<String, String> userPrompts = {
  'userReady': userReady,
  'userNotReady': userNotReady,
};

/// Add some guard rails for how to respond to certain situations and avoid common pitfalls.
// TODO add more guardrails
const String overallGuiderails =
    'If the response is incomprehensible, ask for clarification. If user gets off topic, steer the conversation back on topic. If user is not answering the questions or being silly, empathize with the difficulty of this process and suggest they take a break and return to this conversation at a later date when they are ready to think about the future.';

const String introduction =
    'You are a career advisor. I am in high school and do not know what career I want to choose. It is possible that I am overwhelmed by the options and need help understanding myself and what careers might be good for me. Explain the role of a career advisor. Then ask me a single leading question, for example, "What are your interests?" or "What are your values?" or "What are your capabilities?" to get the conversation started. Do this in under 100 words. $overallGuiderails';

// Questions prompt is used in conjuction with [summaries] in ChatView
const String questions =
    'Do not introduce yourself or explain what you can do. Do not suggest careers. I am in high school and need help undestanding my interests, passions, career values, and priorities. Be informative. Take interest in me and ask me questions. Keep responses under 75 words. Use my answers to inform your next response. If you ask a question, use the question and my answer to inform your next response. $overallGuiderails';

/// Survey Prompts
const surveyPrefix =
    'I am in high school, you are a career advisor helping me understand myself. Use this summary context to generate JSON for a survey.';
const interestSurveyJson =
    '{ "generated_lists": [ { <AREA_OF_INTEREST> : [ <SUBINTEREST>, <ANOTHER_SUBINTEREST>, <ANOTHER_SUBINTEREST>, <ANOTHER_SUBINTEREST>,  <ANOTHER_SUBINTEREST>] }, { <AREA_OF_INTEREST> : [ <SUBINTEREST>, <ANOTHER_SUBINTEREST>, <ANOTHER_SUBINTEREST>, <ANOTHER_SUBINTEREST>,  <ANOTHER_SUBINTEREST>] }, { <AREA_OF_INTEREST> : [ <SUBINTEREST>, <ANOTHER_SUBINTEREST>, <ANOTHER_SUBINTEREST>, <ANOTHER_SUBINTEREST>,  <ANOTHER_SUBINTEREST>] }   ] }';
const String interests =
    '$surveyPrefix. Return JSON in this format $interestSurveyJson.';
const valuesSurveyJson =
    '{ "generated_lists": [ { "Career Values": [ <CONCISE_VALUE_STATEMENT>, <ANOTHER_CONCISE_VALUE_STATEMENT>, <ANOTHER_CONCISE_VALUE_STATEMENT>, <ANOTHER_CONCISE_VALUE_STATEMENT>, <ANOTHER_CONCISE_VALUE_STATEMENT>, <ANOTHER_CONCISE_VALUE_STATEMENT>  ] }]}';
const String careerValues =
    '$surveyPrefix. Return JSON in this format $valuesSurveyJson.';
const strengthsSurveyJson =
    '{ "generated_lists": [ { "Strengths" : [ <CHARACTER_STRENGTH>, <ANOTHER_CHARACTER_STRENGTH>, <ANOTHER_CHARACTER_STRENGTH>, <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>,  <ANOTHER_CHARACTER_STRENGTH>] }  ] }';
const String strengths =
    '$surveyPrefix.  Return JSON in this format $strengthsSurveyJson.';

/// JSON format for career suggestions.
const suggestionsJson =
    '{ "generated_suggestions": [{ "name": <SOME_RANDOM_NAME>, "careerTitle": "Software Engineer"}]}';

const String suggestions =
    'Use this summary context to recommend 1 - 3 careers. Return JSON in this format $suggestionsJson summary context is:';

/// Paths will be an advisor mode feature where discussion focus shifts to future planning.
/// Will be used when user has selected a career focus and is ready to start planning for the future.
const String paths = ""; // TODO

/// User Prompts
const String userReady = 'I am ready for some career suggestions.';
const String userNotReady =
    'I am not yet ready some career suggestions. lets keep exploring my interests, values, and capiablities.';
const String userNeedsSurvey =
    'I need a survey to help me narrow down my interests.';

/// Admin Prompts
const String systemRequestSummary =
    'You write succinct and concise summaries of chat conversations, the fewer words the better.'; // to minimize token usage
const String requestSummary =
    'Based on this conversation and previous summary, write a summary of this high school student\'s interests, values, and capabilities in about 100 words.';
