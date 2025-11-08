/// Simple offline dataset of prompts grouped by category.
const Map<String, List<String>> kPrompts = {
  'Dating': [
    "What’s your go-to comfort food?",
    "What movie could you rewatch forever?",
    "What’s something you’ve learned recently about relationships?",
    "What kind of first date feels perfect to you?",
    "What’s a tiny thing that makes your day better?",
  ],
  'Friends': [
    "What’s a hobby you wish you started earlier?",
    "What’s your favorite low-effort weekend plan?",
    "What song instantly boosts your mood?",
    "What’s a small win from this week?",
    "What’s the funniest thing that’s happened to you recently?",
  ],
  'Work': [
    "What’s one project you’re proud of—and why?",
    "What’s a productivity trick that actually works for you?",
    "If you could fix one thing about office culture, what would it be?",
    "What did you learn from a recent mistake?",
    "What kind of work makes you lose track of time?",
  ],
  'Family': [
    "What’s a family tradition you love?",
    "What’s your earliest happy memory?",
    "Which family recipe needs to be passed on forever?",
    "What’s something you admire about a family member?",
    "What’s a story you hope your family keeps telling?",
  ],
  'Random': [
    "What’s your current tiny obsession?",
    "If today had a title, what would it be?",
    "What’s a hill you’ll playfully die on?",
    "What’s a purchase under €20 that changed your routine?",
    "What’s a question you wish people asked you more?",
  ],
};

/// Each prompt gets a stable ID that combines category and index.
String promptId(String category, int index) => '$category|$index';
