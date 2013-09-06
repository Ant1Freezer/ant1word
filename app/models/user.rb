# encoding: UTF-8
# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(25)
#  email           :string(100)
#  hashed_password :string(40)
#  salt            :string(40)
#  is_admin        :boolean          default(FALSE)
#  daily_limit     :integer          default(10)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#


class User < ActiveRecord::Base

  has_many :flashcards, dependent: :destroy do
    
    # Карточки пользователя, созданные в определённую дату (пока - по времени сервера).
    def created_on(date)
      created_between(date, date)
    end

    def created_between(start_date, end_date)
      # date.to_time - так можно вычислить полночь в часовом поясе сервера.
      where(created_at: start_date.to_time..(end_date.to_time + 1.day))
    end
    

    def grouped_by_date
      flashcards_by_date = {}
      order("id ASC").each do |flashcard|
        date = flashcard.created_at.localtime.to_date
        flashcards_by_date[date] ||= [] # Если nil?, то становится пустым массивом.
        flashcards_by_date[date] << flashcard
      end
      return flashcards_by_date
    end


    def learned
      where("consecutive_successful_repetitions >= ?", WhRails::Application.config.max_consecutive_successful_repetitions)
    end


    def learned_between(start_date, end_date)
      where(learned_on: start_date..end_date)
    end


    def deleted
      Flashcard.unscoped { where(deleted: true).order("updated_at ASC") }
    end

    def deleted_and_not_deleted
      Flashcard.unscoped { where(deleted: [true, false]) }
    end

    def deleted_before(date)
      deleted.where("updated_at < ?", date.to_time)
    end
    
  end



  has_many :repetitions, through: :flashcards do
    
    def planned
      where(run: false)
    end
    

    def run
      where(run: true)
    end
    

    # Два одинаковых метода с разными названиями - чтобы не коверкать язык.
    # planned.for (запланированные на дату), но run.on (выполненные в определённую прошедшую дату).
    def for(date)
      where(actual_date: date)
    end
    

    def on(date)
      where(actual_date: date)
    end

    def between(start_date, end_date)
      where(actual_date: start_date..end_date)
    end
    

    # Доля выученных сегодня карточек, от запланированных. Нужна, чтобы показывать прогресс-бар.
    def progress_today
      today = Date.today
      run.on(today).size.to_f / on(today).size
    end
    

    # Используется для дебага.
    def planned_count_by_date
      planned.group(:actual_date).count
    end
    

    # Если на прошедшие даты у пользователя остались не выполненные повторы, все повторы переносятся.
    # С самой ранней даты, на которую остались повторы, всё переносится на сегодня, остальные - на то же количество дней вперёд.
    def adjust_dates(date)
      first_date = planned.minimum(:actual_date)
      if first_date && first_date < date
        gap = date - first_date
        planned.each do |repetition|
          repetition.increment!(:actual_date, gap)
        end
      end 
    end
    
  end
  


  attr_accessor :password
  
  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i
  
  validates :name, length: { maximum: 25 }
  validates :email, presence: true,
                    length: { maximum: 100 },
                    uniqueness: { case_sensitive: false },
                    format: EMAIL_REGEX
  validates :password, length: {within: 6..25},
                       on: :create
  validates :daily_limit, inclusion: { :in => 1..100 }
  


  before_save { email.downcase! }
  before_save :create_hashed_password
  # Выкинул для того, чтобы feature-тесты было легче писать.
  # after_save :clear_password
  
  
  def total_stats
    nearest_date = repetitions.planned.minimum(:actual_date)
    { total_flashcards: flashcards.count,
      learned_flashcards: flashcards.learned.count,
      total_planned_repetitions: repetitions.planned.count,
      nearest_date: nearest_date,
      planned_repetitions_for_nearest_date: repetitions.planned.for(nearest_date).count,
      last_date_with_planned_repetitions: repetitions.planned.maximum(:actual_date) }
  end


  def stats_for_period(period)
    return {} unless period > 0
    end_date = Date.today
    # На случай, если в функцию будет передан период, не кратный дню.
    # Тогда всё равно произойдёт округление до дня в бОльшую сторону.
    start_date = (end_date.to_time - period + 1.day).to_date
    repetitions_run = repetitions.run.between(start_date, end_date)
    successful_repetitions = repetitions_run.where(successful: true)
    { created: flashcards.created_between(start_date, end_date).count,
      learned: flashcards.learned_between(start_date, end_date).count,
      repetitions_run: repetitions_run.count,
      successful_repetitions: successful_repetitions.count,
      successful_repetitions_percentage: repetitions_run.empty? ? 0 : (successful_repetitions.count.to_f / repetitions_run.count * 100).round }
  end


  def password_match?(password = "")
    if salt.present?
      hashed_password == User.hash_with_salt(password, salt)
    else # Для учётных записей, перекочевавших из старого PHP-шного сайта
      hashed_password == User.hash_without_salt(password)
    end
  end
  

  def self.authenticate(email, password)
    user = User.find_by_email(email)
    if user && user.password_match?(password)
      return user
    else
      return false
    end
  end
  

  def self.make_salt(email = "")
    Digest::SHA1.hexdigest("Use #{email} with #{Time.now} to make salt")
  end
  

  def self.hash_with_salt(password = "", salt = "")
    Digest::SHA1.hexdigest("Put #{salt} on the #{password}")
  end
  

  def self.hash_without_salt(password = "")
    Digest::SHA1.hexdigest(password)
  end



  private
  
  def create_hashed_password
    unless password.blank?
      self.salt = User.make_salt(email) if salt.blank?
      self.hashed_password = User.hash_with_salt(password, salt)
    end
  end
  
  
  def clear_password
    self.password = nil
  end
   
end
