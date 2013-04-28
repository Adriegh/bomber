module('Тестирование модели')

test('Класс Player', () ->
  a = new Player()
  ok(a.name? and a.x? and a.y?, 'конструктор из случайных значений')

  b = new Player(a)
  ok(
    b.name? and b.name is a.name and
    b.x? and b.x is a.x and
    b.y? and b.y is a.y, 'копирующий конструктор'
  )

  c = new Player('test', 10, -15)
  ok(c.name is 'test' and c.x is 10 and c.y is -15, 'конструктор по значениям')

  equal(c.html(), "<div id='test' class='player'>test</div>", 'HTML представление')

  deepEqual(c.raw(), {name: 'test', x : 10, y : -15}, 'получение сырого объекта')

  c.change({x: 100,y: 1000})
  deepEqual(c.raw(), {name: 'test', x : 100, y : 1000}, 'изменение значений объекта')
)