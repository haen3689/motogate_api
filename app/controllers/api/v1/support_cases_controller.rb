class Api::V1::SupportCasesController < ApiController
  def show
    kase = current_user.support_case
    render_success(kase ? kase.as_json(only: %i[status rating feedback_comment resolved_at]) : { status: "none" })
  end

  def rate
    kase = current_user.support_case
    return render_error("ບໍ່ພົບຂໍ້ມູນ", status: :not_found) unless kase
    return render_error("ສາມາດໃຫ້ຄະແນນໄດ້ສະເພາະເຄສທີ່ປິດແລ້ວ") unless kase.status == "resolved"
    return render_error("ໃຫ້ຄະແນນໄປແລ້ວ") if kase.rating.present?

    rating = params[:rating].to_i
    return render_error("ຄະແນນຕ້ອງຢູ່ລະຫວ່າງ 1-5") unless (1..5).cover?(rating)

    kase.update!(rating: rating, feedback_comment: params[:comment])
    render_success(kase.as_json(only: %i[status rating feedback_comment]))
  end
end
