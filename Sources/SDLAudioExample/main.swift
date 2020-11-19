import SDL2

// Adaption of example code from <https://gist.github.com/armornick/3447121>

// absolute path to WAV resource file.
let MUS_PATH = "/Users/ctreffs/Development/personal/game-dev/SDLAudioTest/Sources/Resources/Asteroids.wav"

// gloabl declarations
var audio_buffer: UnsafeMutableBufferPointer<Uint8>?; // global pointer to the audio buffer to be played
var audio_pos = 0 // current offset into the audio buffer
var audio_len: Uint32 = 0 // remaining length of the sample we have to play

/// Print-out the last SDL Error
func printSDLError() {
    print(String(cString: SDL_GetError()))
}

// Print-out current SDL version
func printSDLVersion() {
    print("SDL \(SDL_MAJOR_VERSION).\(SDL_MINOR_VERSION).\(SDL_PATCHLEVEL)")
}
printSDLVersion()

/// audio callback function
/// here you have to copy the data of your audio buffer into the
/// requesting audio buffer (stream)
/// you should only copy as much as the requested length (len)
///
/// aka: `SDL_AudioCallback`
func my_audio_callback(userdata: UnsafeMutableRawPointer?, stream: UnsafeMutablePointer<Uint8>?, len: Int32) {

    if audio_len == 0 {
        return
    }
    var sampleLength = len
    sampleLength = (sampleLength > audio_len) ? Int32(audio_len) : sampleLength

    // copy from one buffer into the other
    SDL_memcpy(stream,
               audio_buffer!.baseAddress!.advanced(by: Int(audio_pos)),
               Int(sampleLength))
    audio_pos += Int(sampleLength)
    audio_len -= Uint32(sampleLength)
}

guard SDL_Init(SDL_INIT_AUDIO) < 1 else {
    printSDLError()
    SDL_Quit()
    exit(-1)
}

// local variables
var wav_length: UInt32 = 0 // length of our sample
var wav_buffer: UnsafeMutablePointer<Uint8>? // buffer containing our audio file
var wav_spec: SDL_AudioSpec = SDL_AudioSpec() // the specs of our piece of music

/* Load the WAV */
// the specs, length and buffer of our wav are filled
guard SDL_LoadWAV_RW(SDL_RWFromFile(MUS_PATH, "rb"),
                     1,
                     &wav_spec,
                     &wav_buffer,
                     &wav_length) != nil else {
    printSDLError()
    SDL_Quit()
    exit(-2)
}

// set the callback function
wav_spec.callback = my_audio_callback
wav_spec.userdata = nil

// set our global variables
audio_buffer = UnsafeMutableBufferPointer(start: wav_buffer!, count: Int(wav_length)) // copy sound buffer
audio_len = wav_length; // copy file length

/* Open the audio device */
guard SDL_OpenAudio(&wav_spec, nil) < 1  else {
    printSDLError()
    SDL_FreeWAV(wav_buffer)
    SDL_Quit()
    exit(-3)
}

/* Start playing */
SDL_PauseAudio(0)
print("Start playing...")

// wait until we're don't playing
while audio_len > 0 {
    SDL_Delay(100)
}
print("Finished playing")

// shut everything down
SDL_CloseAudio()
SDL_FreeWAV(wav_buffer)
SDL_Quit()
