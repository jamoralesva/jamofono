port module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


-- 1. PUERTOS (Definición de firmas de funciones)

-- Puerto de salida: Elm le envía un String a JavaScript
port enviarMensaje : String -> Cmd msg

-- Puerto de entrada: Elm se suscribe a un String proveniente de JavaScript
port recibirMensaje : (String -> msg) -> Sub msg

-- PUERTO DE SALIDA: Envía la nota musical (String) a JS
port reproducirTono : String -> Cmd msg


-- 2. MODELO
type alias Model =
    { textoParaEnviar : String
    , mensajeRecibido : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { textoParaEnviar = ""
      , mensajeRecibido = "Esperando eco del servidor..."
      }
    , Cmd.none 
    )



-- 3. MENSAJES
type Msg
    = EnviarAlServidor
    | MensajeDesdeServidor String
    | TocarNota String



-- 4. ACTUALIZACIÓN (Función Pura)
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnviarAlServidor ->
            -- Emitimos el comando a través del puerto de salida y limpiamos el input
            ( { model | textoParaEnviar = "" }
            , enviarMensaje model.textoParaEnviar 
            )

        MensajeDesdeServidor eco ->
            -- Actualizamos el modelo con la respuesta que JS nos inyectó por el puerto
            ( { model | mensajeRecibido = eco }, Cmd.none )

        TocarNota nota ->
            -- Disparamos la nota por el puerto hacia Tone.js. El modelo no cambia.
            ( model, reproducirTono nota )



-- 5. SUSCRIPCIONES
subscriptions : Model -> Sub Msg
subscriptions _ =
    -- Nos conectamos al puerto de entrada y mapeamos el String nativo al mensaje 'MensajeDesdeServidor'
    recibirMensaje MensajeDesdeServidor


view : Model -> Html Msg
view _ =
    div
        [ style "display" "grid"
        , style "grid-template-columns" "1fr"
        , style "grid-template-rows" "1fr 1fr 1fr 1fr"
        , style "width" "100vw"
        , style "height" "100vh"
        , style "margin" "0"
        , style "padding" "0"
        , style "overflow" "hidden"
        ]
        [ viewArea "C4" "#FF5733" "Nota Do (C4)"
        , viewArea "E4" "#33FF57" "Nota Mi (E4)"
        , viewArea "G4" "#3357FF" "Nota Sol (G4)"
        , viewArea "C5" "#F3FF33" "Nota Do Alto (C5)"
        ]


-- Función auxiliar pura para renderizar cada una de las 4 áreas
viewArea : String -> String -> String -> Html Msg
viewArea nota color etiqueta =
    div
        [ onClick (TocarNota nota)
        , style "background-color" color
        , style "display" "flex"
        --, style "align-items" center
        , style "justify-content" "center"
        , style "font-family" "sans-serif"
        , style "font-size" "1.5rem"
        , style "font-weight" "bold"
        , style "color" "#FFF"
        , style "cursor" "pointer"
        , style "user-select" "none"
        ]
        [ text etiqueta ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }