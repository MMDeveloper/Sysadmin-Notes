location ~ \.php$ {
    fastcgi_pass php;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME  $document_root/$fastcgi_script_name;
    include /etc/nginx/fastcgi_params;
    fastcgi_param HTTPS off;
    fastcgi_param HTTP_PROXY "";
}