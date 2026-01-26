class SessionsController < ApplicationController
  def new
  end

  def create
    email = params[:email].to_s.strip.downcase
    if email.blank?
      flash.now[:alert] = "이메일을 입력해주세요."
      render :new, status: :unprocessable_entity
      return
    end

    identity = Identity.find_by(provider: "email", email: email)
    user = identity&.user

    if user.nil?
      user = User.new(email: email)
      unless user.save
        flash.now[:alert] = user.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
        return
      end

      identity = user.identities.build(provider: "email", email: email)
      unless identity.save
        flash.now[:alert] = identity.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
        return
      end
    end

    raw_token = LoginToken.generate_for!(user, request: request)
    magic_link = auth_magic_url(token: raw_token)

    MagicLinkMailer.with(user: user, magic_link: magic_link).login.deliver_now

    redirect_to login_path, notice: "로그인 링크를 보냈습니다. 메일을 확인해주세요."
  end

  def magic
    token = LoginToken.find_active_by_raw_token(params[:token])
    if token.nil?
      redirect_to login_path, alert: "로그인 링크가 유효하지 않거나 만료되었습니다."
      return
    end

    token.use!
    session[:user_id] = token.user_id

    redirect_to pop_return_to || pastes_path, notice: "로그인되었습니다."
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "로그아웃되었습니다."
  end
end
