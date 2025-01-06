module Jekyll
    class ChatSimulationTag < Liquid::Block
  
      def render(context)
        content = super.strip
        messages = content.lines.map do |line|
          type, text = line.split(':', 2).map(&:strip)
          { type: type, text: text }
        end
  
        messages_json = messages.to_json
  
        <<~HTML
<style>
  div.app {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    margin: 0;
    background-color: #f0f0f0;
    font-family: Arial, sans-serif;
  }
  .phone {
    width: 300px;
    height: 500px;
    border: 16px solid #333;
    border-radius: 36px;
    background-color: #fff;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
  }
  .screen {
    flex: 1;
    padding: 10px;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
  }
  .message {
    max-width: 80%;
    margin: 5px 0;
    padding: 10px;
    border-radius: 10px;
    position: relative;
  }
  .message.sent {
    align-self: flex-end;
    background-color: #dcf8c6;
  }
  .message.received {
    align-self: flex-start;
    background-color: #f1f0f0;
  }
  .message p {
    margin: 0;
  }
  typing-indicator {
    display: flex;
    align-items: center;
    margin: 5px 0;
  }
  .typing-indicator span {
    display: inline-block;
    width: 8px;
    height: 8px;
    margin: 0 2px;
    background-color: #ccc;
    border-radius: 50%;
    animation: blink 1.4s infinite both;
  }
  .typing-indicator span:nth-child(2) {
    animation-delay: 0.2s;
  }
  .typing-indicator span:nth-child(3) {
    animation-delay: 0.4s;
  }
  @keyframes blink {
    0%, 80%, 100% {
      opacity: 0;
    }
    40% {
      opacity: 1;
    }
  }
</style>
<div id="app"></div>
<script src="https://cdn.jsdelivr.net/npm/phonejs/dist/phonejs.min.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', () => {
    const messages = #{messages_json};

    const app = document.getElementById('app');
    const phone = document.createElement('div');
    phone.className = 'phone';
    app.appendChild(phone);

    const screen = document.createElement('div');
    screen.className = 'screen';
    phone.appendChild(screen);

    let messageIndex = 0;

    function showTypingIndicator() {
      const typingIndicator = document.createElement('div');
      typingIndicator.className = 'typing-indicator';
      typingIndicator.innerHTML = '<span></span><span></span><span></span>';
      screen.appendChild(typingIndicator);
      screen.scrollTop = screen.scrollHeight;
      return typingIndicator;
    }

    function addMessage(message) {
      const messageElement = document.createElement('div');
      messageElement.className = `message ${message.type}`;
      messageElement.innerHTML = `<p>${message.text}</p>`;
      screen.appendChild(messageElement);
      screen.scrollTop = screen.scrollHeight;
    }

    function showNextMessage() {
      if (messageIndex < messages.length) {
        const message = messages[messageIndex];
        const typingIndicator = showTypingIndicator();

        setTimeout(() => {
          screen.removeChild(typingIndicator);
          addMessage(message);
          messageIndex++;
          showNextMessage();
        }, 2000);
      }
    }

    showNextMessage();
  });
</script>
        HTML
      end
    end
  end
  
  Liquid::Template.register_tag('chat_simulation', Jekyll::ChatSimulationTag)