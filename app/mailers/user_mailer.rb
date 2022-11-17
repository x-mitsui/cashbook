class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: "x_mitsui@163.com", subject: "hi test")
  end
end
