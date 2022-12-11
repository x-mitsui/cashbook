class UserMailer < ApplicationMailer
  def welcome_email(email)
    # desc降序排序，让其只拿最新的code
    validation_code = ValidationCode.order(created_at: :desc).find_by_email(email)
    # p validation_code.code
    @code = validation_code.code
    mail(to: email, subject: "[#{@code}]山竹记账验证码")
  end
end
