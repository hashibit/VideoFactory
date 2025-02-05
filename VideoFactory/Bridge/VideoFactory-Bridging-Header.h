//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <mpv/client.h>
#include <mpv/render_gl.h>


// MUST FIRST include ffmpeg headers here!
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/audio_fifo.h>
#include <libavutil/imgutils.h>
#include <libswresample/swresample.h>
#include <libswscale/swscale.h>

// although our application header has ffmpeg headers included (via extern C),
// we still need to include in current file FIRST.
#include "ffmpeg_processor_impl.hpp"
