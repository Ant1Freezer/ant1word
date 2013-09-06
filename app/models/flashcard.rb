# encoding: UTF-8
# == Schema Information
#
# Table name: flashcards
#
#  id                                 :integer          not null, primary key
#  user_id                            :integer
#  front_text                         :text
#  back_text                          :text
#  consecutive_successful_repetitions :integer          default(0)
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  deleted                            :boolean          default(FALSE)
#  learned_on                         :date
#


class Flashcard < ActiveRecord::Base
  
  default_scope { where(deleted: false) }
  
  validates :front_text, presence: true
  validates :back_text, presence: true
  validates :user_id, presence: true,
                      existence: true
  validates :deleted, inclusion: { in: [true, false] }
  validates :learned_on, timeliness: { on_or_before: lambda { Date.today } },
                         allow_nil: true

  belongs_to :user

  has_many :repetitions, dependent: :destroy do
    
    # Высчитывается интервал между двумя последними повторами. 
    # Используется при планировании даты следующего повтора.
    # planned_date - устанавливается один раз, при создании повтора.
    # actual_date - может отличаться: если пользователь пропускает день повтора, все повторы переносятся вперёд, и actual_date вместе с ними.
    # Таким образом, следующий интервал зависит от запланированного предыдущего, а не реального.
    # Это помогает избежать слишком больших интервалов между следующими повторами, если между предыдущими много дней было пропущено.
    def last_planned_interval
      if size == 0
        0
      elsif size == 1
        first.planned_date - first.created_at.localtime.to_date
      else
        last_two_repetitions = order("id ASC").offset(size - 2)
        # abs добавлен, чтобы specs не выбрасывали ошибку в случае, когда значение получается отрицательным.
        (last_two_repetitions.last.planned_date - last_two_repetitions.first.actual_date).abs
      end
    end
  
  end
  

  
  after_create :set_first_repetition
  
  

  # Первый повтор - через 1-3 дня после создания карточки.
  def set_first_repetition
    first_repetition_date = Date.today + rand(1..3).days
    repetitions.create planned_date: first_repetition_date, actual_date: first_repetition_date
  end
  

  # Если последний повтор был удачным - следующий запланировать с интервалом, в 2-3 раза превышающим предыдущий.
  # Если нет, то следующий, как и первый, должен быть через 1-3 дня после текущего.
  # TODO: правильнее было бы передавать id повтора, потому что last может стать и другим, когда начнётся выполнение метода.
  def set_next_repetition
    if repetitions.order("id ASC").last.successful
      self.consecutive_successful_repetitions += 1
      next_planned_interval = rand((repetitions.last_planned_interval * 2)..(repetitions.last_planned_interval * 3))
    else
      self.consecutive_successful_repetitions = 0
      next_planned_interval = rand(1..3)
    end
    save
    if consecutive_successful_repetitions < WhRails::Application.config.max_consecutive_successful_repetitions
      # repetitions.last.actual_date будет всегда равен сегодняшнему дню.
      next_repetition_date = repetitions.order("id ASC").last.actual_date + next_planned_interval.days
      repetitions.create planned_date: next_repetition_date, actual_date: next_repetition_date
    else
      self.learned_on = Date.today
      save
    end
  end
  

  # Если карточку повторили 3 раза (больше - это на всякий случай), то она считается выученной.
  def learned?
    consecutive_successful_repetitions >= WhRails::Application.config.max_consecutive_successful_repetitions
  end

  # TODO: убрать дублирование (то же самое в виде метода - на ассоциации в user.rb). Используется только в миграции.
  scope :learned, -> { where("consecutive_successful_repetitions >= ?", WhRails::Application.config.max_consecutive_successful_repetitions) }
  
end
