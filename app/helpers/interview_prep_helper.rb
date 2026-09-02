module InterviewPrepHelper
  # Coach replies may contain light Markdown. Render it, then sanitize to a
  # small tag whitelist so a prompt-injected reply cannot inject markup.
  MARKDOWN_TAGS = %w[p br strong em b i ul ol li blockquote code pre]

  def interview_markdown(text)
    html = Kramdown::Document.new(text.to_s).to_html
    sanitize(html, tags: MARKDOWN_TAGS)
  end
end
