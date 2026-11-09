#include "model.h"
#ifdef _WIN32
#include "../source/skeet/nl_hypotheses.h"
#define SR_EXPORT extern "C" __declspec(dllexport)
#else
#define SR_EXPORT extern "C" __attribute__((visibility("default")))
#endif
namespace { stock_resolver::Engine engine; }
SR_EXPORT unsigned sr_abi_version(){return 0x00010001;}
SR_EXPORT unsigned sr_snapshot_bytes(){return sizeof(stock_resolver::Snapshot);}
SR_EXPORT unsigned sr_decision_bytes(){return sizeof(stock_resolver::Decision);}
SR_EXPORT unsigned sr_mode_enabled(){
#ifdef _WIN32
    return nl_hypotheses::selected_mode==nl_hypotheses::StockResolver;
#else
    return 1; // Host tests exercise the enabled mode without loading the game.
#endif
}
SR_EXPORT void sr_reset(){engine.reset();}
SR_EXPORT void sr_forget(unsigned player){engine.forget(player);}
SR_EXPORT unsigned sr_feed(const stock_resolver::Snapshot* sample,float threshold,stock_resolver::Decision* decision){return sample&&decision&&engine.feed(*sample,threshold,*decision);}
SR_EXPORT unsigned sr_head_hit(unsigned player,unsigned identity,unsigned generation){return engine.hit(player,identity,generation);}
SR_EXPORT void sr_stats(stock_resolver::Stats* out){if(out)*out=engine.stats();}
SR_EXPORT unsigned sr_history(unsigned player,stock_resolver::Snapshot* out,unsigned capacity){return engine.history(player,out,capacity);}
SR_EXPORT void sr_frame(float dt){engine.frame(dt);}
SR_EXPORT void sr_frame_stats(stock_resolver::FrameStats* out){if(out)*out=engine.frame_stats();}
