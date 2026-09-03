require "ruby_llm/schema"
class AiResponseSchema < RubyLLM::Schema
  string :order_advice,
         description: "If applicable, One sentence instruction to recommend user about the position inside a resume. With a specific job title and JD, most relevant project or work experience (if any) needs to be near the top of the resume page. Use a simple markdown, but cannot be a table or pipes"

  string :summary_advice,
         description: "If applicable, One sentence instruction to recommend user about the top executive summary. Given a specific job title and JD, the tech stacks should match resume in bold. Summary should not be no longer than 5 lines. Better put the years of experience on the first line (example. With X months of experience in Java....). Use a simple markdown, but cannot be a table or pipes"

  array :addutional_advice,
        of: :string,
        description: "More recommedations to recommend user about the content of a tech resume, given a specific job title and JD. Array should consist of maximum 5 elements. Use a simple markdown, but cannot be a table or pipes"
end
