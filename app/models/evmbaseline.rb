class Evmbaseline < ActiveRecord::Base
  unloadable

  attr_protected :id

  has_many :evmbaselineIssues, dependent: :delete_all
  belongs_to :author, class_name: 'User'
  belongs_to :project

  validates :subject, presence: true

  def minimum_start_date
    evmbaselineIssues.minimum(:start_date)
  end

  def maximum_due_date
    evmbaselineIssues.maximum(:due_date)
  end

  def bac
    evmbaselineIssues.sum(:estimated_hours).round(1)
  end

  acts_as_event title: proc { |o| l(:title_evm_tab) + ':' + o.subject },
                description: l(:label_ativity_message_new),
                datetime: :created_on,
                type: proc { |o| 'EvmBaseine-' + (o.created_on < o.updated_on ? 'edit' : 'new') },
                url: proc { |o| { controller: 'evmbaselines', action: 'index', project_id: o.project } }

  acts_as_activity_provider scope: joins(:project),
                            permission: :view_evm_baselines,
                            type: 'evmbaseline',
                            author_key: :author_id
end
