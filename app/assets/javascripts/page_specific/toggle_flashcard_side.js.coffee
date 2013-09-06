$ ->
	$('.flashcard-repeat, .flashcard-hidden').click (event) ->
		visibleSide = $(event.currentTarget)
		invisibleSide = $('.flashcard-hidden')
		visibleSide.
			removeClass('flashcard-repeat').
			addClass('flashcard-hidden')
		invisibleSide.
			removeClass('flashcard-hidden').
			addClass('flashcard-repeat')
		false