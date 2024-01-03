LOCALE = "en"

FRAMEWORK = "ESX" -- "ESX" | "QB"

-- Set this to true if you're using onesync, allows distance checking on server
ONESYNC = false

-- Cooldown for players to submit forms
FORM_COOLDOWN = 15 * 60 * 1000

-- Used only if USE_OX_TARGET is set to false
LOAD_DISTANCE = 10.0

/*
    Shows First name, Last name in the discord log.
    IMPORTANT NOTE FOR ESX USERS:
    You need to have esx_identity in order for this to work properly.
*/
USE_IDENTITY = false

-- Replaces Float Notify with Target
USE_OX_TARGET = false

-- Radius for Target, only used if you're using ox_target
TARGET_DISTANCE = 3.0

-- Defines which key is used for opening forms. Used only if you're not using ox_target.
OPEN_FORM_KEY = "E"

-- For more details, refer to https://docs.fivem.net/natives/?_0x788E7FD431BD67F1
FLOAT_NOTIFY_STYLE = { 1, 1, 111, -1, 3, 0 }

-- Used only if USE_OX_TARGET is set to false. Distance for displaying the float notify.
FLOAT_NOTIFY_DISTANCE = 1.5

FORMS = {
    MISSION_ROW = {
        coords = vector3(440.83834838867,-981.13397216797,30.689332962036),
        label = 'LSPD Form',
        questions = {
            ["wayjoc"] = {
                label = "Why are you joining our company?",
                maxLength = 100,
                minLength = 30
            },
            ["tusay"] = {
                label = "Tell us something about yourself",
            }
        }
    },
    PILLBOX_HOSPITAL = {
        coords = vector3(298.89642333984,-584.50939941406,43.26086807251),
        label = 'EMS Form',
        color = "#c0392b",
        questions = {
            ["wayjoc"] = {
                label = "Why are you joining our company?",
                maxLength = 100,
                minLength = 30
            },
            ["tusay"] = {
                label = "Tell us something about yourself",
                maxLength = 100,
                minLength = 30
            }
        }
    }
}