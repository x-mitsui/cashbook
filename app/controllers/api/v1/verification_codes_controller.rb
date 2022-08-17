class Api::V1::VerificationCodesController < ApplicationController
  def create
    code = SecureRandom.random_number.to_s[2..7]
    varification_code = VerificationCode.new email: params[:email],
                                             kind: "signed_in",
                                             code: code
    if varification_code.save
      head 200
    else
      render json: { errors: varification_code.errors }
    end
  end
end
