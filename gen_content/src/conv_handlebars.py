def convert_handle_bar(inp: str, app_lang: str, learn_lang: str) -> str:
    """
    Converts {{app_lang}} and {{learn_lang}} to their respective languages
    Converts {{app_country}} and {{learn_country}} to their respective countries
    """
    inp = inp.replace("{{app_lang}}", langs[app_lang].english_name)
    inp = inp.replace("{{learn_lang}}", langs[learn_lang].english_name)
    inp = inp.replace("{{app_country}}", langs[app_lang].contry_name)
    inp = inp.replace("{{learn_country}}", langs[learn_lang].contry_name)
    return inp


class Lang:
    def __init__(self, code, contry_name, english_name):
        self.code = code
        self.contry_name = contry_name
        self.english_name = english_name


langs = {
    "en": Lang("en", "the United States", "English"),
    "de": Lang("de", "Germany", "German"),
    "es": Lang("es", "Spain", "Spanish"),
}
