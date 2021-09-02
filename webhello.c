#include <stdio.h> 
#include <stdlib.h> 
#include <errno.h> 
#include <string.h> 
#include <sys/types.h> 
#include <arpa/inet.h>
#include <netinet/in.h> 
#include <sys/socket.h> 
#include <sys/wait.h> 
#include <unistd.h> 

#define WEB_SERVER_ADDR INADDR_ANY
#define WEB_SERVER_PORT 8000
#define CONNECT_QUEUE_LENGTH 10

int main(int argc, char *argv[]) {

   // Create the listening socket
   int listen_fd;
   if ((listen_fd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
      perror("socket");
      exit(1);
   }

   // Bind to specified interface and port
   struct sockaddr_in me = (const struct sockaddr_in){0};
   me.sin_family = AF_INET;
   me.sin_addr.s_addr = WEB_SERVER_ADDR;
   me.sin_port = htons(WEB_SERVER_PORT);
   if (1 == bind(listen_fd, (struct sockaddr *)&me, sizeof(struct sockaddr))) {
      perror("bind");
      exit(1);
   }

   // Create service queue, and start listening
   if (listen(listen_fd, CONNECT_QUEUE_LENGTH) == -1) {
      perror("listen");
      exit(1);
   }

   // Loop forever accepting connections and forking processes to handle them
   while (1) {

      // Accept connection from a single connecting client
      unsigned int sin_size = sizeof(struct sockaddr_in);
      struct sockaddr_in client;
      int client_fd = accept(listen_fd, (struct sockaddr *)&client, &sin_size);
      if (-1 == client_fd) {
         perror("accept");
         continue;
      }

      // This child process handles the connection until done
      if (!fork()) {

         // Consume and "log" the request
         const char* client_addr = inet_ntoa(client.sin_addr);
         char request_buffer[BUFSIZ];
         bzero(request_buffer, BUFSIZ);
         (void) read(client_fd, request_buffer, BUFSIZ); 
         printf("\nClient %s sent:\n%s", client_addr, request_buffer); 

         // Construct the HTML content
         char html[BUFSIZ];
         char *html_template =
           "<!DOCTYPE html>\r\n"
           "<html>\r\n<head>\r\n"
           "<meta charset=\"utf-8\">\r\n"
           "<title>MiniMosquito</title>\r\n"
           "</head>\r\n<body>\r\nHello, \"%s\".\r\n</body>\r\n</html>\r\n";
         (void) snprintf(html, BUFSIZ, html_template, client_addr);

         // Construct the HTTP response, including the HTML content
         char http[BUFSIZ];
         char *http_template =
           "HTTP/1.0 200 OK\r\n"
           "Content-Type: text/html; charset=utf-8\r\n"
           "Content-Length: %d\r\n\r\n%s\r\n";
         (void) snprintf(http, BUFSIZ, http_template, 1 + strlen(html), html);

         // Log the response (for debugging)
         printf("--> Responding with: \n%s\n", http); 

         // Send the response and clean up
         if (-1 == send(client_fd, http, 1 + strlen(http), 0))
            perror("send");
         close(client_fd);
         exit(0);

      } else {

         // This is the parent process. We don't need the client_fd here.
         close(client_fd);
      }

      // Clean up any child processes that have already exited
      while(waitpid(-1,NULL,WNOHANG) > 0);
   }
}
