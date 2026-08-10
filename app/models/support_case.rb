class SupportCase < ApplicationRecord
  belongs_to :user
  belongs_to :admin_user, optional: true

  STATUSES = %w[open pending resolved].freeze
  validates :status, inclusion: { in: STATUSES }

  scope :open_cases, -> { where(status: "open") }
  scope :pending, -> { where(status: "pending") }
  scope :resolved, -> { where(status: "resolved") }
  scope :unresolved, -> { where(status: %w[open pending]) }

  # Round-robin: picks the online, opted-in agent who was assigned a case
  # longest ago (never-assigned agents come first) and hands them this
  # case. Returns nil (leaves the case unassigned) if nobody is online —
  # it gets picked up the moment an agent comes online and opens the
  # case list, rather than silently stuck with no owner forever.
  def self.assign_next_agent!(support_case)
    agents = AdminUser.where(role: "admin", is_support_agent: true, support_online: true)
    return nil if agents.empty?

    last_assigned = SupportCase.where(admin_user_id: agents.map(&:id))
                                .group(:admin_user_id).maximum(:created_at)

    next_agent = agents.min_by { |a| last_assigned[a.id] || Time.at(0) }
    support_case.update!(admin_user: next_agent)
    next_agent
  end

  # Called whenever a new inbound (customer) message arrives — creates
  # the case on first contact, or flips it back to "open" (agent needs
  # to respond) if the customer messages again while pending/resolved.
  # Assignment sticks with the same agent unless the case has no agent
  # yet (brand new, or the previous agent went offline/opted out).
  def self.touch_for_user!(user)
    kase = SupportCase.find_or_initialize_by(user: user)
    kase.last_message_at = Time.current
    kase.status = "open" unless kase.status == "open"
    kase.save!

    agent = kase.admin_user
    reassign_needed = agent.nil? || !(agent.is_support_agent? && agent.support_online?)
    assign_next_agent!(kase) if reassign_needed
    kase
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id user_id admin_user_id status last_message_at resolved_at rating feedback_comment created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user admin_user]
  end
end
