ActiveAdmin.register_page "Support Chat" do
  menu label: "ຫ້ອງສົນທະນາ", priority: 12, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  controller do
    def index
      if params[:room] == "next"
        next_case = SupportCase.where(admin_user_id: current_admin_user.id, status: %w[open pending])
                                .order(Arel.sql("status = 'open' desc"), last_message_at: :asc)
                                .first
        if next_case
          redirect_to admin_support_chat_path(user_id: next_case.user_id) and return
        end
      end
      super
    end
  end

  content title: "ຫ້ອງສົນທະນາລູກຄ້າ" do
    if params[:room] == "next"
      render partial: "active_admin/support_chat_list", locals: { empty_room_notice: true }
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
      user.chat_messages.where(sender: "user", read_by_admin: false).update_all(read_by_admin: true)
      kase = SupportCase.find_or_create_by!(user: user) { |k| k.last_message_at = Time.current }
      render partial: "active_admin/support_chat_conversation", locals: { user: user, kase: kase }
    else
      render partial: "active_admin/support_chat_list", locals: { empty_room_notice: false }
    end
  end

  page_action :reply, method: :post do
    user = User.find(params[:user_id])
    if params[:body].to_s.strip.present?
      msg = user.chat_messages.create!(sender: "agent", body: params[:body].to_s.strip)

      kase = SupportCase.find_or_create_by!(user: user) { |k| k.admin_user = current_admin_user }
      kase.update!(
        admin_user: kase.admin_user || current_admin_user,
        status: "pending",
        last_message_at: Time.current
      )

      ActionCable.server.broadcast("chat_#{user.id}", { message: msg.as_json })
      ActionCable.server.broadcast("admin_chat", {
        user_id: user.id,
        user_phone: user.phone_number,
        user_name: [user.first_name, user.last_name].compact.join(" ").presence || user.name,
        message: msg.as_json
      })
    end
    redirect_to "/admin/support_chat?user_id=#{user.id}"
  end

  page_action :assign_to_me, method: :post do
    user = User.find(params[:user_id])
    kase = SupportCase.find_or_create_by!(user: user)
    kase.update!(admin_user: current_admin_user)
    redirect_to "/admin/support_chat?user_id=#{user.id}"
  end

  page_action :resolve, method: :post do
    user = User.find(params[:user_id])
    kase = SupportCase.find_by!(user: user)
    kase.update!(status: "resolved", resolved_at: Time.current)
    redirect_to "/admin/support_chat?user_id=#{user.id}"
  end

  page_action :reopen, method: :post do
    user = User.find(params[:user_id])
    kase = SupportCase.find_by!(user: user)
    kase.update!(status: "open", resolved_at: nil)
    SupportCase.assign_next_agent!(kase) if kase.admin_user_id.nil?
    redirect_to "/admin/support_chat?user_id=#{user.id}"
  end

  page_action :toggle_online, method: :post do
    current_admin_user.update!(support_online: !current_admin_user.support_online)
    redirect_back fallback_location: "/admin/support_chat"
  end
end
