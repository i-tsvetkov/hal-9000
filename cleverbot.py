import sys
from chatterbotapi import ChatterBotFactory, ChatterBotType

factory = ChatterBotFactory()
bot = factory.create(ChatterBotType.CLEVERBOT)
bot_session = bot.create_session()

print bot_session.think(sys.argv[1])

