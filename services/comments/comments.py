from flask import Flask, jsonify
import mysql.connector as mysql

service = Flask("comments")

DATABASE_SERVER = "database"
DATABASE_USER = "root"
DATABASE_PASS = "admin"
DATABASE_NAME = "pokeinfo"

def get_database_connection():
    connection = mysql.connect(host=DATABASE_SERVER, user=DATABASE_USER, password=DATABASE_PASS, database=DATABASE_NAME)

    return connection

@service.get("/info")
def get_info():
    return jsonify(
        description = "pokeinfo comments management",
        version = "1.0"
    )

@service.get("/comments/<int:feed_id>/<int:page>/<int:page_size>")
def get_comments(feed_id, page, page_size):
    comments = []

    connection = get_database_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT id as comment_id, feed as produto_id, comment, nome, account, DATE_FORMAT(data, '%Y-%m-%d %H:%i') as data " +
                   "FROM comments " +
                   "WHERE feed = " + str(feed_id) + " ORDER BY data DESC " +
                   "LIMIT " + str((page - 1) * page_size) + ", " + str(page_size))
    comments = cursor.fetchall()
    connection.close()

    return jsonify(comments)


@service.post("/add/<int:feed_id>/<string:nome>/<string:account>/<string:comment>")
def add_comment(feed_id, nome, account, comment):
    result = jsonify(status = "ok", error = "")

    connection = get_database_connection()
    cursor = connection.cursor()
    try:
        cursor.execute(
            f"INSERT INTO comments(feed, nome, account, comment, data) VALUES({feed_id}, '{nome}', '{account}', '{comment}', NOW())")
        connection.commit()
    except:
        connection.rollback()
        result = jsonify(status = "error", error = "errorr while trying to add comment.")

    connection.close()

    return result


@service.delete("/remove/<int:comment_id>")
def remove_comment(comment_id):
    result = jsonify(status = "ok", error = "")

    connection = get_database_connection()
    cursor = connection.cursor()
    try:
        cursor.execute(
            f"DELETE FROM comments WHERE id = {comment_id}")
        connection.commit()
    except:
        connection.rollback()
        result = jsonify(status = "error", error = "error while deleting comment")

    connection.close()

    return result


if __name__ == "__main__":
    service.run(host="0.0.0.0", debug=True)