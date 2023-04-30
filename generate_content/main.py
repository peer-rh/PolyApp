# <..> - Converts to app lang
# <<..>> - Converts to learn lang
# {} - App Lang english name
# {{}} - Learn Lang english name
# [] - App Lang Country
# [[]] - Learn Lang Country
# /// - Generate audio url


# Convert into actual templates
# Fill in voice setting
# Generate Translations
# Generate TTS
# Store TTS in Firebase Storage
import json

avatar_to_path = {
        "man": "Man",
        "woman": "Woman"
        }

avatar_to_voice = {
        "man": {
            "en": "en-US-Wavenet-D",
            "es": "es-ES-Wavenet-D",
            }
        , "women": {
            "en": "en-US-Wavenet-C",
            "es": "es-ES-Wavenet-C",
            }
        }

def convertToTemplateFormat(path: str, out_path: str):
    data = json.load(open(path))
    new_data = []
    for i in data:
        new_data.append(i)
