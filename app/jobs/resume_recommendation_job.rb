class ResumeRecommendationJob < ApplicationJob
  queue_as :default

  def perform(resume, job_opening)
    chat = RubyLLM.chat.with_schema(AiResponseSchema)
    response = chat.ask(
      "You are a professional tech recruiter with over 10 years of experience. You mainly recruit for new grads and mid-level engineers. I am a newbie who has #{resume.content} in my resume content. Currently applying for #{job_opening.title} job with the following JD: #{job_opening.content}. Give me precise and brief recommendations. If something is already fulfilled, no need to give recommendation (For example, if their top part of resume is already tech projects, no need to give position recommendations)."
    )
    result = response.content

    @resume.update!(
      ai_response: {
        order_advice: result["order_advice"],
        summary_advice: result["summary_advice"],
        addutional_advice: result["addutional_advice"]
      }
    )

    # Turbo::StreamsChannel.broadcast_replace_to(dream, target: dom_id(dream), partial: "shared/show_image",
                                                      locals: { dream: dream })
  end
end
