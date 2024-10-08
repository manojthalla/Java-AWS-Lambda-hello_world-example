package com.mthalla.hello.world.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.mthalla.hello.world.lambda.models.Request;
import com.mthalla.hello.world.lambda.models.Response;

public class MainFunction implements RequestHandler<Request, Response> {

    public Response handleRequest(Request request, Context context) {
        Response response = new Response();
        response.setMessage(String.format("Hello %s to AWS Lambda World!", request.getName()));
        return response;
    }
}
