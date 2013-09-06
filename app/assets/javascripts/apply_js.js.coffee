$('html').removeClass('no-js').addClass('js')
###
Эта строка - чтобы не было мигающего выпадающего меню.
Элемент dropdownMenu ещё не появился,
но нужный стиль мы ему уже добавляем.
###
$('head').
	append('<style> #dropdownMenu { display: none; } </style>')