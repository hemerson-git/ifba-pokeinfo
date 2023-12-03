from flask import Flask, jsonify
import mysql.connector as mysql

service = Flask("likes")

DATABASE_SERVER = "database"
DATABASE_USER = "root"
DATABASE_PASS = "admin"
DATABASE_NAME = "pokeinfo"

def get_connection_com_bd():
    connection = mysql.connect(host=DATABASE_SERVER, user=DATABASE_USER, password=DATABASE_PASS, database=DATABASE_NAME)

    return connection

@service.get("/info")
def get_info():
    return jsonify(
        description = "pokeinfo likes management.",
        version = "1.0"
    )

@service.get("/likes_per_feed/<int:feed_id>")
def likes_per_pokemon(feed_id):
    connection = get_connection_com_bd()
    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT count(*) as quantity " +  
        "FROM likes " +
        "WHERE likes.feed = " + str(feed_id)
    )
    likes = cursor.fetchone()

    connection.close()

    return jsonify(likes = likes["quantity"])

@service.get("/liked/<string:account>/<int:feed_id>")
def liked(account, feed_id):
    connection = get_connection_com_bd()
    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT count(*) as quantity " +  
        "FROM likes " +
        "WHERE likes.feed = " + str(feed_id) + " AND likes.email = '" + account + "'"
    )
    likes = cursor.fetchone()

    connection.close()

    return jsonify(liked = likes["quantity"] > 0)

@service.post("/like/<string:account>/<int:feed_id>")
def like(account, feed_id):
    result = jsonify(status = "ok", error = "")

    connection = get_connection_com_bd()
    cursor = connection.cursor()
    try:
        cursor.execute(f"INSERT INTO likes(feed, email) VALUES ({str(feed_id)}, '{account}')")
        connection.commit()
    except:
        connection.rollback()
        result = jsonify(status = "error", error = "error while trying to send like.")

    connection.close()

    return result

@service.post("/unlike/<string:account>/<int:feed_id>")
def unlike(account, feed_id):
    result = jsonify(status = "ok", error = "")

    connection = get_connection_com_bd()
    cursor = connection.cursor()
    try:
        cursor.execute(f"DELETE FROM likes WHERE feed = {str(feed_id)} AND email = '{account}'")
        connection.commit()
    except:
        connection.rollback()
        result = jsonify(status = "error", error = "error while trying to remove like")

    connection.close()

    return result


if __name__ == "__main__":
    service.run(host="0.0.0.0", debug=True)