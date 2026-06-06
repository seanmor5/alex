if Code.ensure_loaded?(Kino.JS.Live) do
  defmodule Alex.Kino.View do
    @moduledoc """
    A Livebook widget that displays frames streamed from a native `Alex.Env`.

    This is the *server-authoritative* renderer: the emulator runs in the BEAM
    (driven by your agent or script) and each frame is pushed to the browser as a
    raw RGB binary and drawn onto a canvas. Use it to watch a policy that runs in
    Elixir — see `Alex.Kino.view/2` and `Alex.Kino.push_frame/2`.
    """

    use Kino.JS
    use Kino.JS.Live

    @doc false
    def new(rgb, {height, width}, opts \\ []) do
      scale = Keyword.get(opts, :scale, 3)
      Kino.JS.Live.new(__MODULE__, {rgb, height, width, scale})
    end

    @doc false
    def push(kino, rgb, {height, width}) do
      Kino.JS.Live.cast(kino, {:frame, rgb, height, width})
    end

    @impl true
    def init({rgb, height, width, scale}, ctx) do
      {:ok, assign(ctx, rgb: rgb, height: height, width: width, scale: scale)}
    end

    @impl true
    def handle_connect(ctx) do
      {:ok, frame_payload(ctx), ctx}
    end

    @impl true
    def handle_cast({:frame, rgb, height, width}, ctx) do
      ctx = assign(ctx, rgb: rgb, height: height, width: width)
      broadcast_event(ctx, "frame", frame_payload(ctx))
      {:noreply, ctx}
    end

    defp frame_payload(ctx) do
      info = %{
        height: ctx.assigns.height,
        width: ctx.assigns.width,
        scale: ctx.assigns.scale
      }

      {:binary, info, ctx.assigns.rgb}
    end

    asset "main.js" do
      """
      export function init(ctx, payload) {
        const canvas = document.createElement("canvas");
        canvas.style.imageRendering = "pixelated";
        canvas.style.background = "#000";
        ctx.root.appendChild(canvas);
        const cctx = canvas.getContext("2d");

        function draw([info, buffer]) {
          const { width, height, scale } = info;
          canvas.width = width * scale;
          canvas.height = height * scale;

          const rgb = new Uint8Array(buffer);
          const rgba = new Uint8ClampedArray(width * height * 4);
          for (let i = 0; i < width * height; i++) {
            rgba[i * 4] = rgb[i * 3];
            rgba[i * 4 + 1] = rgb[i * 3 + 1];
            rgba[i * 4 + 2] = rgb[i * 3 + 2];
            rgba[i * 4 + 3] = 255;
          }

          const tmp = document.createElement("canvas");
          tmp.width = width;
          tmp.height = height;
          tmp.getContext("2d").putImageData(new ImageData(rgba, width, height), 0, 0);

          cctx.imageSmoothingEnabled = false;
          cctx.drawImage(tmp, 0, 0, canvas.width, canvas.height);
        }

        draw(payload);
        ctx.handleEvent("frame", draw);
      }
      """
    end
  end

  defmodule Alex.Kino.Play do
    @moduledoc """
    A Livebook widget for *playing* an Atari game interactively in the browser.

    This is the *client-authoritative* renderer: ALE's official WebAssembly build
    runs in the browser at full frame rate, reads the keyboard, and renders to a
    canvas with no per-frame round-trip to the server. The Elixir side only
    supplies configuration (which ROM, settings). See `Alex.Kino.play/2`.

    The WebAssembly module (and the ROMs it bundles) are loaded from a CDN by
    default, pinned to the ALE version ALEx was built against, so the in-browser
    emulator matches the native one byte-for-byte.

    Controls: arrow keys move, <space> fires, <r> resets.
    """

    use Kino.JS
    use Kino.JS.Live

    @doc false
    def new(rom, config) do
      Kino.JS.Live.new(__MODULE__, {rom, config})
    end

    @impl true
    def init({rom, config}, ctx) do
      {:ok, assign(ctx, rom: rom, config: config)}
    end

    @impl true
    def handle_connect(ctx) do
      payload = %{
        rom: ctx.assigns.rom,
        wasm_base: ctx.assigns.config.wasm_base,
        repeat_action_probability: ctx.assigns.config.repeat_action_probability,
        scale: ctx.assigns.config.scale
      }

      {:ok, payload, ctx}
    end

    # The browser reports episode results back; we simply forward them to the
    # Livebook process inbox so the user can `receive` them if they care.
    @impl true
    def handle_event("episode", %{"reward" => reward, "frames" => frames}, ctx) do
      send(ctx.assigns.config.caller, {:alex_episode, %{reward: reward, frames: frames}})
      {:noreply, ctx}
    end

    asset "main.js" do
      """
      // ALE integer actions, indexed by [up,down,left,right,fire] state.
      const A = {
        NOOP: 0, FIRE: 1, UP: 2, RIGHT: 3, LEFT: 4, DOWN: 5,
        UPRIGHT: 6, UPLEFT: 7, DOWNRIGHT: 8, DOWNLEFT: 9,
        UPFIRE: 10, RIGHTFIRE: 11, LEFTFIRE: 12, DOWNFIRE: 13,
        UPRIGHTFIRE: 14, UPLEFTFIRE: 15, DOWNRIGHTFIRE: 16, DOWNLEFTFIRE: 17
      };

      function actionFor(keys) {
        const { up, down, left, right, fire } = keys;
        let base = A.NOOP;
        if (up && right) base = A.UPRIGHT;
        else if (up && left) base = A.UPLEFT;
        else if (down && right) base = A.DOWNRIGHT;
        else if (down && left) base = A.DOWNLEFT;
        else if (up) base = A.UP;
        else if (down) base = A.DOWN;
        else if (left) base = A.LEFT;
        else if (right) base = A.RIGHT;

        if (!fire) return base;
        switch (base) {
          case A.UP: return A.UPFIRE;
          case A.DOWN: return A.DOWNFIRE;
          case A.LEFT: return A.LEFTFIRE;
          case A.RIGHT: return A.RIGHTFIRE;
          case A.UPRIGHT: return A.UPRIGHTFIRE;
          case A.UPLEFT: return A.UPLEFTFIRE;
          case A.DOWNRIGHT: return A.DOWNRIGHTFIRE;
          case A.DOWNLEFT: return A.DOWNLEFTFIRE;
          default: return A.FIRE;
        }
      }

      function loadScript(src) {
        return new Promise((resolve, reject) => {
          const s = document.createElement("script");
          s.src = src;
          s.onload = resolve;
          s.onerror = () => reject(new Error("failed to load " + src));
          document.head.appendChild(s);
        });
      }

      export async function init(ctx, payload) {
        const base = payload.wasm_base.endsWith("/") ? payload.wasm_base : payload.wasm_base + "/";

        const status = document.createElement("div");
        status.style.fontFamily = "monospace";
        status.textContent = "Loading ALE WebAssembly…";
        ctx.root.appendChild(status);

        const canvas = document.createElement("canvas");
        canvas.style.imageRendering = "pixelated";
        canvas.style.background = "#000";
        canvas.style.display = "block";
        canvas.tabIndex = 0;
        ctx.root.appendChild(canvas);
        const cctx = canvas.getContext("2d");

        try {
          await loadScript(base + "ale.js");
          const ALE = await createALEModule({ locateFile: (p) => base + p });
          const ale = new ALE.ALEInterface();
          ale.setBool("display_screen", false);
          ale.setBool("sound", false);
          ale.setFloat("repeat_action_probability", payload.repeat_action_probability);
          ale.loadROM("/roms/" + payload.rom + ".bin");

          const width = ale.getScreenWidth();
          const height = ale.getScreenHeight();
          const scale = payload.scale;
          canvas.width = width * scale;
          canvas.height = height * scale;

          const tmp = document.createElement("canvas");
          tmp.width = width;
          tmp.height = height;
          const tctx = tmp.getContext("2d");

          function render() {
            const rgb = ale.getScreenRGB();
            const rgba = new Uint8ClampedArray(width * height * 4);
            for (let i = 0; i < width * height; i++) {
              rgba[i * 4] = rgb[i * 3];
              rgba[i * 4 + 1] = rgb[i * 3 + 1];
              rgba[i * 4 + 2] = rgb[i * 3 + 2];
              rgba[i * 4 + 3] = 255;
            }
            tctx.putImageData(new ImageData(rgba, width, height), 0, 0);
            cctx.imageSmoothingEnabled = false;
            cctx.drawImage(tmp, 0, 0, canvas.width, canvas.height);
          }

          const keys = { up: false, down: false, left: false, right: false, fire: false };
          const bind = { ArrowUp: "up", ArrowDown: "down", ArrowLeft: "left", ArrowRight: "right", " ": "fire" };

          canvas.addEventListener("keydown", (e) => {
            if (e.key === "r" || e.key === "R") { ale.resetGame(); totalReward = 0; frames = 0; }
            if (bind[e.key] !== undefined) { keys[bind[e.key]] = true; e.preventDefault(); }
          });
          canvas.addEventListener("keyup", (e) => {
            if (bind[e.key] !== undefined) { keys[bind[e.key]] = false; e.preventDefault(); }
          });
          canvas.focus();

          let totalReward = 0;
          let frames = 0;
          status.textContent =
            "ALE " + ALE.ALEInterface.getVersion() + " — " + payload.rom +
            " | click the canvas, then arrows + space. (r) resets.";

          function loop() {
            totalReward += ale.act(actionFor(keys));
            frames += 1;
            render();
            if (ale.gameOver()) {
              ctx.pushEvent("episode", { reward: totalReward, frames });
              ale.resetGame();
              totalReward = 0;
              frames = 0;
            }
            requestAnimationFrame(loop);
          }

          render();
          requestAnimationFrame(loop);
        } catch (error) {
          status.textContent = "Error: " + error.message;
          throw error;
        }
      }
      """
    end
  end

  defmodule Alex.Kino do
    @moduledoc """
    Livebook integration for ALEx.

    Two complementary ways to bring Atari into a Livebook:

      * `play/2` — play a game yourself, with the keyboard, at full speed. ALE's
        official WebAssembly build runs in the browser; nothing round-trips to the
        server. Great for trying a game or recording human demonstrations.

      * `view/2` / `push_frame/2` — watch an `Alex.Env` that an agent or script is
        driving in the BEAM. Frames are streamed from the native emulator to a
        canvas. This is the only way to visualize a policy implemented in Elixir.

    Additionally, any `%Alex.Env{}` renders as its current screen when it is the
    result of a Livebook cell (via the `Kino.Render` protocol).

    Requires the optional `:kino` dependency. The browser emulator used by `play/2`
    is loaded from a CDN by default and therefore needs network access in the
    Livebook runtime.
    """

    alias Alex.{Env, Screen}

    # Matches the ALE version ALEx is built against; see mix.exs @ale_version.
    @wasm_version "0.12.0"
    @wasm_base "https://unpkg.com/@farama/ale-wasm@#{@wasm_version}"

    @doc """
    Returns an interactive, keyboard-playable widget for `rom`.

    `rom` is a game name recognized by ALE (e.g. `"breakout"`); the browser build
    bundles the ROMs, so no local ROM directory is required.

    ## Options

      * `:scale` — integer pixel scale for the canvas (default `3`)
      * `:repeat_action_probability` — sticky actions (default `0.0` for crisp
        human control)
      * `:wasm_base` — base URL for the `@farama/ale-wasm` assets (default a
        version-pinned unpkg URL)

    Episode results are sent to the calling process as
    `{:alex_episode, %{reward: number, frames: integer}}` messages, which you can
    `receive` if you want to log scores.
    """
    @spec play(String.t(), keyword()) :: Kino.JS.Live.t()
    def play(rom, opts \\ []) when is_binary(rom) do
      config = %{
        scale: Keyword.get(opts, :scale, 3),
        repeat_action_probability: Keyword.get(opts, :repeat_action_probability, 0.0),
        wasm_base: Keyword.get(opts, :wasm_base, @wasm_base),
        caller: self()
      }

      Alex.Kino.Play.new(rom, config)
    end

    @doc """
    Returns a widget showing the current screen of `env`, ready to receive live
    frame updates via `push_frame/2`.

    ## Options

      * `:scale` — integer pixel scale for the canvas (default `3`)
    """
    @spec view(Env.t(), keyword()) :: Kino.JS.Live.t()
    def view(%Env{} = env, opts \\ []) do
      {rgb, _shape, _dtype} = Screen.rgb(env)
      Alex.Kino.View.new(rgb, env.screen_dims, opts)
    end

    @doc """
    Pushes the current screen of `env` to a `view/2` widget.

    Call this in your stepping loop to animate an agent in real time.
    """
    @spec push_frame(Kino.JS.Live.t(), Env.t()) :: :ok
    def push_frame(view, %Env{} = env) do
      {rgb, _shape, _dtype} = Screen.rgb(env)
      Alex.Kino.View.push(view, rgb, env.screen_dims)
    end
  end

  defimpl Kino.Render, for: Alex.Env do
    def to_livebook(env) do
      env |> Alex.Kino.view() |> Kino.Render.to_livebook()
    end
  end
end
