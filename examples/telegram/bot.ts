import { Bot } from "grammy";

const bot = new Bot('5814239636:AAH1G-yI0Xr7AGi60di8-RtPNXH9vRmAQPQ');


bot.command("start", async (ctx) => {
    await ctx.reply("cool test!");
    // const me = await bot.api.getMe();
    // await ctx.reply(me.username);
    await ctx.reply( "*Hi\\!* _Welcome_ to [grammY](https://grammy.dev)\\.",
        { parse_mode: "MarkdownV2" });
    const txt = ctx.message?.text;
    console.log(txt);
});
// Handle other messages.
bot.on("message", (ctx) => ctx.reply("Got another message!"));

// Now that you specified how to handle messages, you can start your bot.
// This will connect to the Telegram servers and wait for messages.

// Start the bot.
bot.start();

// Reply to any message with "Hi there!".
// bot.on("message", (ctx) => ctx.reply("Hi there ...!"));
// bot.command("start", (ctx) => {/* ... */});
// bot.command("start", async (ctx) => {
//     await ctx.reply("Hi! I can only read messages that explicitly reply to me!", {
//       // Make Telegram clients automatically show a reply interface to the user.
//       reply_markup: { force_reply: true },
//     });
//   });

// bot.api.sendMessage(
//     12345,
//     "*Hi\\!* _Welcome_ to [grammY](https://grammy.dev)\\.",
//     { parse_mode: "MarkdownV2" },
//   );

