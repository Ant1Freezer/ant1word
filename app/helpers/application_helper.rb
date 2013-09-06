# encoding: UTF-8

module ApplicationHelper

  def full_title(title = nil)
    base_title = "Ant1Word"
    if title.nil? or title.blank?
      base_title
    else
      "#{title} &mdash; #{base_title}".html_safe
    end
  end

  # Хелпер для определения, активен ли определённый пункт меню.
  def active_class(paths = [])
    # На случай, если пользователь передал не массив, а строку.
    paths = [paths] if paths.class != Array
    return "active" if paths.include?(request.fullpath)
    return ""
  end

  
  # Класс для выделения цветом пункта меню "Создать", если на сегодня ещё не все карточки созданы.
  def create_class
    return "to-do" if current_user.flashcards.created_on(current_date).size < current_user.daily_limit
    return ""
  end

  
  # Класс для выделения цветом пункта меню "Повторить" в зависимости от того, всё ли запланированное на сегодня повторено.
  def repeat_class
    return "to-do" if current_user.repetitions.planned.for(current_date).size > 0
    return "inactive"
  end


  # Метод для дебага.
  def planned_repetitions_count_by_date
    Hash[current_user.repetitions.planned_count_by_date.sort] if current_user.present?
  end


  # Хелпер для вывода сообщения об ошибке сохранения в базу.
  def errors(object)
    if object.present?
      object.errors.full_messages
    end
  end
  
end
