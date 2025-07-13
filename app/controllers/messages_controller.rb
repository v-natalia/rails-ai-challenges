class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are a Teaching Assistant.\n\nI am a student at the Le Wagon Web Development Bootcamp, learning how to code.\n\nHelp me break down my problem into small, actionable steps, without giving away solutions.\n\nAnswer concisely in markdown."

  def new
    @challenge = Challenge.find(params[:challenge_id])
    @message = Message.new
  end

  def create
    @challenge = Challenge.find(params[:challenge_id])
    @message = Message.new(role: "user", content: params[:message][:content], challenge: @challenge)
    if @message.save
      @chat = RubyLLM.chat
      response = @chat.with_instructions(instructions).ask(@message.content)
      Message.create(role: "assistant", content: response.content, challenge: @challenge)
      redirect_to challenge_messages_path(@challenge)
    else
      render :new
    end
  end

  private

  def challenge_context
    "Here is the context of the challenge: #{@challenge.content}."
  end

  def instructions
    [SYSTEM_PROMPT, challenge_context, @challenge.system_prompt].compact.join("\n\n")
  end
end
