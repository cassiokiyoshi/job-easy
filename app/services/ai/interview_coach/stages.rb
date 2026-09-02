module Ai
  module InterviewCoach
    # The five stages the coach works through, in order. This is the single
    # source of truth for the syllabus shown in the UI and for the stage
    # descriptions injected into the system prompt. Progression itself is not
    # tracked in the database - the coach follows the conversation.
    module Stages
      Stage = Struct.new(
        :key, :number, :title, :goal, :what_good_looks_like, :hard_questions,
        keyword_init: true
      )

      ALL = [
        Stage.new(
          key: "career_change_story",
          number: 1,
          title: "Career-change story",
          goal: "Explain why they are moving into software development, told with " \
                "intent rather than apology.",
          what_good_looks_like: "A short, confident narrative that connects their " \
                                "previous career or studies to development, names " \
                                "what pulled them toward code, and shows momentum " \
                                "(bootcamp, projects, self-study). No apologising " \
                                "for a late start.",
          hard_questions: [
            "Why should we hire someone with no professional development experience?",
            "You have not shipped code in a company before. Why should we take the risk?",
            "What makes you think you will not want to switch careers again in a year?"
          ]
        ),
        Stage.new(
          key: "project_walkthrough",
          number: 2,
          title: "Project walkthrough",
          goal: "Walk through one project the way they would in a code review: the " \
                "problem, the approach, and what they would do differently.",
          what_good_looks_like: "They pick one bootcamp or personal project, state " \
                                "the problem it solved, explain a concrete technical " \
                                "decision and its trade-offs, and name something they " \
                                "would change with hindsight. Specifics over buzzwords.",
          hard_questions: [
            "What was the hardest bug you hit, and how did you actually diagnose it?",
            "Why did you choose that stack instead of something simpler?",
            "If a senior reviewed this PR, what would they push back on?"
          ]
        ),
        Stage.new(
          key: "motivation",
          number: 3,
          title: "志望動機 for this role",
          goal: "Say why this company and why now - specific to this role, not a " \
                "generic 'why I want to be a developer'.",
          what_good_looks_like: "They reference something concrete about this company " \
                                "or product, connect it to their own interests or " \
                                "projects, and explain why now is the right moment. " \
                                "It could not be pasted into another application.",
          hard_questions: [
            "We get hundreds of applicants. Why do you want this job specifically?",
            "What do you actually know about what we build?",
            "If you got an offer from a bigger company tomorrow, what would you do?"
          ]
        ),
        Stage.new(
          key: "experience_gap",
          number: 4,
          title: "Handling the experience gap",
          goal: "Reframe 'we want 3 years of experience' into what they do have plus " \
                "what they are eager to learn.",
          what_good_looks_like: "They acknowledge the gap without shrinking, map their " \
                                "bootcamp and project work and transferable skills from " \
                                "their previous career onto the job's requirements, and " \
                                "name specifically what they want to learn on the job.",
          hard_questions: [
            "The job asks for 3 years. You have none. Convince me.",
            "How long before you can contribute without hand-holding?",
            "What part of this role are you least prepared for?"
          ]
        ),
        Stage.new(
          key: "training_questions",
          number: 5,
          title: "Questions to ask about training",
          goal: "Prepare questions to ask the company about how they support junior " \
                "developers: code review, onboarding, mentorship.",
          what_good_looks_like: "Two or three specific questions - who reviews their " \
                                "PRs, what onboarding looks like in the first month, " \
                                "whether there is a mentor or buddy, how the team gives " \
                                "feedback. Questions that show they plan to grow here.",
          hard_questions: [
            "You are the interviewer now. What would you want to know before joining?",
            "What would make you turn down an offer from us?"
          ]
        )
      ]

      def self.stages
        ALL
      end

      def self.find(key)
        ALL.find { |stage| stage.key == key.to_s }
      end

      def self.first
        ALL.first
      end
    end
  end
end
