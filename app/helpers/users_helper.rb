# encoding: utf-8

module UsersHelper
  def total_stats(stats)
    [{ name: "Всего карточек:",
       value: stats[:total_flashcards] },
     { name: "Из них выучено:",
       value: stats[:learned_flashcards] },
     { name: "Всего запланировано повторов:",
       value: stats[:total_planned_repetitions] },
     { name: "Ближайшие повторы:",
       value: "#{stats[:planned_repetitions_for_nearest_date]} (#{stats[:nearest_date]})" },
     { name: "Запланировано повторов до:",
       value: stats[:last_date_with_planned_repetitions] }
    ]
  end

  def stats_for_period(stats)
    [{ name: "Создано:",
       value: stats[:created] },
     { name: "Выучено:",
       value: stats[:learned] },
     { name: "Всего повторов:",
       value: stats[:repetitions_run] },
     { name: "Из них успешных:",
       value: "#{stats[:successful_repetitions]} (#{stats[:successful_repetitions_percentage]}%)" }
     ]
  end
end
