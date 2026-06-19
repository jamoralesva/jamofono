port module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


-- 1. PUERTOS (Definición de firmas de funciones

-- Puerto para enviar tonos tocadas localmente hacia JS
port enviarTono : String -> Cmd msg

-- Puerto para escuchar tonos que llegan de otros usuarios desde JS
port notaRecibida : (String -> msg) -> Sub msg

-- PUERTO DE SALIDA: Envía el tono/nota musical (String) a JS
port reproducirTono : String -> Cmd msg


-- 2. MODELO
type alias Model =
    { tonoParaEnviar : String
    , tonoRecibido : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { tonoParaEnviar = ""
      , tonoRecibido = "Esperando eco del servidor..."
      }
    , Cmd.none 
    )



-- 3. MENSAJES
type Msg
    = EnviarAlServidor
    | MensajeDesdeServidor String
    | TocarNota String

-- Algoritmos de elección
type NodeRole = Spokes | Hub
type ElectionState = Idle | Electing | WaitingForCoordinator

type alias Model = 
    { id : Int
    , role : NodeRole
    , election : ElectionState
    , activeNodes : List Int
    }

-- 4. ACTUALIZACIÓN (Función Pura)
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnviarAlServidor ->
            -- Emitimos el comando a través del puerto de salida y limpiamos el input
            ( { model | tonoRecibido = "" }
            , enviarTono model.tonoParaEnviar 
            )

        MensajeDesdeServidor eco ->
            -- Actualizamos el modelo con la respuesta que JS nos inyectó por el puerto
            ( { model | tonoRecibido = eco }, Cmd.none )

        TocarNota nota ->
            -- Disparamos la nota por el puerto hacia Tone.js. El modelo no cambia.
            ( model, reproducirTono nota )



-- 5. SUSCRIPCIONES
subscriptions : Model -> Sub Msg
subscriptions _ =
    -- Nos conectamos al puerto de entrada y mapeamos el String nativo al mensaje 'MensajeDesdeServidor'
    notaRecibida MensajeDesdeServidor


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